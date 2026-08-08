from pathlib import Path

from jinja2 import Environment, FileSystemLoader
from weasyprint import HTML

from .layouts import get_layout
from .themes import get_theme

TEMPLATES_DIR = Path(__file__).parent / "templates"

_env = Environment(loader=FileSystemLoader(str(TEMPLATES_DIR)), autoescape=True)

# Arabic label + short badge glyph per meal slot. Lives here rather than in
# a template because five layouts render meals and none of them should have
# to repeat the mapping.
MEAL_META: dict[str, tuple[str, str]] = {
    "breakfast": ("فطور", "ف"),
    "lunch": ("غداء", "غ"),
    "dinner": ("عشاء", "ع"),
    "salad": ("سلطة", "سل"),
    "snack": ("سناك", "سن"),
}


def _ingredient_line(ing: dict) -> str:
    item = (ing.get("item") or "").strip()
    amount = ing.get("amount")
    if amount in (None, ""):
        return item
    unit = (ing.get("unit") or "").strip()
    return f"{item} — {amount} {unit}".strip()


def _meal_view(meal: dict) -> dict:
    """Flattens one plan_meal (which may draw its name/ingredients either
    from a linked bank recipe or from per-plan overrides) into the handful
    of plain fields a template actually paints."""
    recipe = meal.get("recipe") or {}
    label, badge = MEAL_META.get(
        meal.get("meal_type"), (meal.get("meal_type") or "وجبة", "•")
    )

    # `custom_ingredients` being an explicit empty list means "this meal has
    # no ingredient list", which is different from it being absent (fall
    # back to the recipe's). Only `None` triggers the fallback.
    ingredients = meal.get("custom_ingredients")
    if ingredients is None:
        ingredients = recipe.get("ingredients") or []

    return {
        "label": label,
        "badge": badge,
        "name": meal.get("custom_name") or recipe.get("name") or "—",
        "ingredients": [_ingredient_line(ing) for ing in ingredients if ing],
        "image_url": recipe.get("image_url"),
        "tip": recipe.get("tip"),
    }


def _build_view_model(context: dict) -> dict:
    """Adds the derived, template-facing values to the raw data graph coming
    from the repository: the resolved design and palette, the normalized
    meals, and the cover's at-a-glance counts.

    Design and palette are two independent columns on the plan and both
    fall back to their defaults when absent — which is also what happens on
    a deployment whose `plans` table predates either column.
    """
    plan = context.get("plan") or {}
    days = context.get("days") or []
    for day in days:
        day["meal_views"] = [_meal_view(meal) for meal in (day.get("meals") or [])]

    drinks = context.get("drinks") or []
    supplements = context.get("supplements") or []

    return {
        **context,
        "layout": get_layout(plan.get("pdf_layout")),
        "theme": get_theme(plan.get("theme")),
        "stats": {
            "days": len(days),
            "meals": sum(len(day["meal_views"]) for day in days),
            "supplements": len(supplements),
            "drinks": len(drinks),
        },
    }


def render_plan_pdf(context: dict) -> bytes:
    """Renders the `plan.html` template tree (cover → one page per day →
    notes/instructions/closing pages) and rasterizes it to a single PDF.

    Which design gets rendered is decided by `plan.pdf_layout` — plan.html
    dispatches to templates/layouts/<id>/. The color palette is orthogonal
    and comes from `plan.theme` (see app/themes.py).

    `base_url` is set to the templates directory so the relative font path
    in shared.css (`../fonts/Cairo-Variable.ttf`) and any relative asset
    URLs resolve correctly and offline.
    """
    html = _env.get_template("plan.html").render(**_build_view_model(context))
    return HTML(string=html, base_url=str(TEMPLATES_DIR)).write_pdf()
