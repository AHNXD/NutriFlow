from fastapi import APIRouter, HTTPException, Response

from .. import plan_repository
from ..pdf_renderer import render_plan_pdf
from ..schemas import GeneratePlanPdfRequest
from ..supabase_rest import SupabaseRestError

router = APIRouter()


@router.post("/generate-plan-pdf")
async def generate_plan_pdf(payload: GeneratePlanPdfRequest) -> Response:
    try:
        context = await plan_repository.get_plan_pdf_context(payload.plan_id)
    except plan_repository.PlanNotFoundError:
        raise HTTPException(status_code=404, detail="الخطة غير موجودة")
    except SupabaseRestError as exc:
        raise HTTPException(status_code=502, detail=str(exc))

    pdf_bytes = render_plan_pdf(context)
    patient = context["plan"]["patient_name"].replace(" ", "-")
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f'attachment; filename="nutriflow-{patient}.pdf"'
        },
    )
