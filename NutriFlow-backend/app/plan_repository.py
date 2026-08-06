"""Fetches one plan's full data graph from Supabase and shapes it into the
plain dict structure the Jinja2 templates render (see templates/day_page.html
etc.). Mirrors supabase/schema.sql's tables — see that file for the source
of truth on columns.
"""

from __future__ import annotations

from . import supabase_rest as db


class PlanNotFoundError(Exception):
    pass


async def get_plan_pdf_context(plan_id: str) -> dict:
    plan = await db.select_one("plans", {"id": f"eq.{plan_id}", "select": "*"})
    if plan is None:
        raise PlanNotFoundError(plan_id)

    days = await db.select(
        "plan_days",
        {"plan_id": f"eq.{plan_id}", "select": "*", "order": "day_number"},
    )

    if days:
        # One query for every day's meals (instead of one query per day —
        # this plan could have up to 31 days) — PostgREST's `in.()` filter
        # takes a comma-separated id list. Also embeds the linked bank
        # recipe (if any) directly in each meal row via the `recipe_id`
        # foreign key.
        day_ids = ",".join(day["id"] for day in days)
        all_meals = await db.select(
            "plan_meals",
            {
                "plan_day_id": f"in.({day_ids})",
                "select": "*,recipe:recipes(*)",
                "order": "sort_order",
            },
        )
        meals_by_day: dict[str, list[dict]] = {day["id"]: [] for day in days}
        for meal in all_meals:
            meals_by_day[meal["plan_day_id"]].append(meal)
        for day in days:
            day["meals"] = meals_by_day[day["id"]]

    drink_links = await db.select(
        "plan_drinks",
        {"plan_id": f"eq.{plan_id}", "select": "drink:helper_drinks(*)"},
    )
    drinks = [link["drink"] for link in drink_links if link.get("drink")]

    supplement_links = await db.select(
        "plan_supplements",
        {"plan_id": f"eq.{plan_id}", "select": "*,supplement:supplements(*)"},
    )

    food_lists = await db.select("food_lists", {"select": "*", "order": "list_type,category"})
    allowed = [f for f in food_lists if f["list_type"] == "allowed"]
    forbidden = [f for f in food_lists if f["list_type"] == "forbidden"]

    return {
        "plan": plan,
        "days": days,
        "drinks": drinks,
        "supplements": supplement_links,
        "allowed_foods": allowed,
        "forbidden_foods": forbidden,
    }
