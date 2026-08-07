import logging
from urllib.parse import quote

from fastapi import APIRouter, HTTPException, Response

from .. import plan_repository
from ..pdf_renderer import render_plan_pdf
from ..schemas import GeneratePlanPdfRequest
from ..supabase_rest import SupabaseRestError

router = APIRouter()
logger = logging.getLogger(__name__)


@router.post("/generate-plan-pdf")
async def generate_plan_pdf(payload: GeneratePlanPdfRequest) -> Response:
    try:
        context = await plan_repository.get_plan_pdf_context(payload.plan_id)
    except plan_repository.PlanNotFoundError:
        raise HTTPException(status_code=404, detail="الخطة غير موجودة")
    except SupabaseRestError as exc:
        raise HTTPException(status_code=502, detail=str(exc))

    try:
        pdf_bytes = render_plan_pdf(context)
    except Exception as exc:
        # Was previously unguarded, so any WeasyPrint/Jinja failure (bad
        # image fetch, font issue, etc.) surfaced as Starlette's opaque
        # generic 500 with no detail at all. Log the full traceback server
        # side and return at least the exception message to the client.
        logger.exception("PDF rendering failed for plan_id=%s", payload.plan_id)
        raise HTTPException(status_code=500, detail=f"فشل توليد ملف PDF: {exc}")

    # HTTP header values are Latin-1 only, but patient names are Arabic —
    # a plain `filename="nutriflow-<name>.pdf"` crashes Response's header
    # encoding outright (UnicodeEncodeError) rather than degrading. Send a
    # safe ASCII fallback for `filename=` plus the real name UTF-8/percent
    # -encoded in `filename*=`, per RFC 6266 — the standard way to have a
    # non-ASCII download name while staying spec-compliant.
    filename_utf8 = quote(f"nutriflow-{context['plan']['patient_name']}.pdf")
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": (
                f'attachment; filename="nutriflow-plan.pdf"; '
                f"filename*=UTF-8''{filename_utf8}"
            )
        },
    )
