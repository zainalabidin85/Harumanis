from datetime import date, timedelta
from sqlalchemy.orm import Session
from models.farm import GrowthPhase


def predict_harvest(size_cm: float, db: Session) -> tuple[date, int, int]:
    """
    Returns (estimated_harvest_date, days_to_harvest, resolved_stage).
    Size is the primary signal; YOLO growth_stage is a fallback only.
    """
    phase = (
        db.query(GrowthPhase)
        .filter(GrowthPhase.size_min_cm <= size_cm, GrowthPhase.size_max_cm > size_cm)
        .first()
    )

    if phase is None:
        # Size is outside all defined ranges — clamp to nearest boundary stage.
        if size_cm >= 8.0:
            # Larger than expected — treat as pre-harvest
            phase = db.query(GrowthPhase).filter(GrowthPhase.stage == 4).first()
        else:
            # Smaller than expected — treat as earliest stage
            phase = db.query(GrowthPhase).filter(GrowthPhase.stage == 1).first()

    if phase is None:
        days = 14
        resolved_stage = 4
    else:
        days = phase.days_to_harvest
        resolved_stage = phase.stage

    harvest_date = date.today() + timedelta(days=days)
    return harvest_date, days, resolved_stage
