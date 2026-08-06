from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers.plan_pdf import router as plan_pdf_router

app = FastAPI(title="NutriFlow PDF Service", version="0.1.0")

# The Flutter app calls this from mobile + desktop builds under different
# origins (no origin at all on native), so a wildcard is the pragmatic
# choice for this internal, single-dietitian tool (spec §1).
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(plan_pdf_router)


@app.get("/")
@app.get("/health")
def health() -> dict:
    """Also the endpoint n8n pings every 24-48h to keep the Render free
    instance warm (spec §2, §7)."""
    return {"status": "ok"}
