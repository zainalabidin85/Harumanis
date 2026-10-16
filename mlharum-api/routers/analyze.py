from typing import Optional

from fastapi import APIRouter, File, Header, HTTPException, UploadFile

from services.i18n import resolve_language, t
from services.pulp_analyzer import PulpNotDetected, analyze_pulp

router = APIRouter()


@router.post("/pulp")
async def analyze_pulp_image(
    file: UploadFile = File(...),
    accept_language: Optional[str] = Header(default=None),
):
    if not (file.content_type or "").startswith("image/"):
        raise HTTPException(status_code=422, detail="File must be an image.")
    data = await file.read()
    if not data:
        raise HTTPException(status_code=422, detail="Empty file received.")
    try:
        return analyze_pulp(data)
    except PulpNotDetected:
        raise HTTPException(
            status_code=422,
            detail=t("pulp.not_detected", resolve_language(accept_language)),
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {exc}") from exc
