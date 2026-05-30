from datetime import date, timedelta
from sqlalchemy.orm import Session
from models.farm import GrowthPhase


def predict_harvest(size_cm: float, growth_stage: int, db: Session) -> tuple[date, int, int]:
    """
    Returns (estimated_harvest_date, days_to_harvest, resolved_stage).
    Size is the primary signal; YOLO growth_stage is a fallback only.
    """
    # Size is the measured value — use it as the primary signal.
    # YOLO stage is a visual estimate and is only used as fallback when size is out of range.
    phase = (
        db.query(GrowthPhase)
        .filter(GrowthPhase.size_min_cm <= size_cm, GrowthPhase.size_max_cm > size_cm)
        .first()
    )

    if phase is None:
        phase = db.query(GrowthPhase).filter(GrowthPhase.stage == growth_stage).first()

    if phase is None:
        # Size is beyond all known phases — treat as pre-harvest
        days = 14
        resolved_stage = 4
    else:
        days = phase.days_to_harvest
        resolved_stage = phase.stage

    harvest_date = date.today() + timedelta(days=days)
    return harvest_date, days, resolved_stage
