from fastapi import APIRouter, File, HTTPException, UploadFile

from services.pulp_analyzer import analyze_pulp

router = APIRouter()


@router.post("/pulp")
async def analyze_pulp_image(file: UploadFile = File(...)):
    if not (file.content_type or "").startswith("image/"):
        raise HTTPException(status_code=422, detail="File must be an image.")
    data = await file.read()
    if not data:
        raise HTTPException(status_code=422, detail="Empty file received.")
    try:
        return analyze_pulp(data)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {exc}") from exc
