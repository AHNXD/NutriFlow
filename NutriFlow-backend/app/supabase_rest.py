"""Thin PostgREST client.

We talk to Supabase's auto-generated REST API directly over httpx instead of
pulling in the `supabase-py` package: this service only ever *reads* data to
render a PDF, so the extra weight of gotrue/realtime/storage3 clients isn't
worth it on a Render free-tier cold start (spec §6 explicitly allows either
`supabase-py` or "REST مباشر").
"""

from __future__ import annotations

import httpx

from .config import get_settings


class SupabaseRestError(RuntimeError):
    def __init__(self, status_code: int, detail: str):
        super().__init__(f"Supabase REST error {status_code}: {detail}")
        self.status_code = status_code
        self.detail = detail


def _client() -> httpx.AsyncClient:
    settings = get_settings()
    key = settings.supabase_service_role_key
    return httpx.AsyncClient(
        base_url=f"{settings.supabase_url}/rest/v1",
        headers={
            "apikey": key,
            "Authorization": f"Bearer {key}",
        },
        timeout=20.0,
    )


async def select(path: str, params: dict) -> list[dict]:
    """GET a PostgREST resource. `params` uses PostgREST filter syntax,
    e.g. {"id": "eq.<uuid>", "select": "*,recipe:recipes(*)"}.
    """
    async with _client() as client:
        response = await client.get(f"/{path}", params=params)
    if response.status_code >= 400:
        raise SupabaseRestError(response.status_code, response.text)
    return response.json()


async def select_one(path: str, params: dict) -> dict | None:
    rows = await select(path, params)
    return rows[0] if rows else None
