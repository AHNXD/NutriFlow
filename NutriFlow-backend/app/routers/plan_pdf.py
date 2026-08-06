import logging

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

    patient = context["plan"]["patient_name"].replace(" ", "-")
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f'attachment; filename="nutriflow-{patient}.pdf"'
        },
    )
