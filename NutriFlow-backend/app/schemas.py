from pydantic import BaseModel


class GeneratePlanPdfRequest(BaseModel):
    plan_id: str
