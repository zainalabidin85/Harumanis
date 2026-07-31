from datetime import date, timedelta
from sqlalchemy.orm import Session
from models.farm import GrowthPhase


def predict_harvest(size_cm: float, db: Session) -> tuple[date, int, int]:
    """
    Returns (estimated_harvest_date, days_to_harvest, resolved_stage).
    Size is the primary signal; YOLO growth_stage is a fallback only.

    Resolves to the highest-numbered stage whose size_min_cm the fruit has
    reached. This naturally supports an open-ended top stage (no size_max_cm
    needed) and stays correct if stage boundaries change.
    """
    phase = (
        db.query(GrowthPhase)
        .filter(GrowthPhase.size_min_cm <= size_cm)
        .order_by(GrowthPhase.stage.desc())
        .first()
    )

    if phase is None:
        # Smaller than every defined stage's minimum — clamp to the earliest stage.
        phase = db.query(GrowthPhase).order_by(GrowthPhase.stage.asc()).first()

    if phase is None:
        days = 49
        resolved_stage = 3
    else:
        days = phase.days_to_harvest
        resolved_stage = phase.stage

    harvest_date = date.today() + timedelta(days=days)
    return harvest_date, days, resolved_stage
