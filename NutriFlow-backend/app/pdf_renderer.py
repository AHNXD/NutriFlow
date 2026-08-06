from pathlib import Path

from jinja2 import Environment, FileSystemLoader
from weasyprint import HTML

TEMPLATES_DIR = Path(__file__).parent / "templates"

_env = Environment(loader=FileSystemLoader(str(TEMPLATES_DIR)), autoescape=True)


def render_plan_pdf(context: dict) -> bytes:
    """Renders the `plan.html` template tree (cover → one page per day →
    notes/instructions/closing pages) and rasterizes it to a single PDF.

    `base_url` is set to the templates directory so the relative font path
    in styles.css (`../fonts/Cairo-Variable.ttf`) and any relative asset
    URLs resolve correctly and offline.
    """
    html = _env.get_template("plan.html").render(**context)
    return HTML(string=html, base_url=str(TEMPLATES_DIR)).write_pdf()
