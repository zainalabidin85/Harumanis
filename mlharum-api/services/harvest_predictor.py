from datetime import date, timedelta
from sqlalchemy.orm import Session
from models.farm import GrowthPhase


def predict_harvest(size_cm: float, growth_stage: int, db: Session) -> tuple[date, int]:
    """
    Returns (estimated_harvest_date, days_to_harvest) based on size and growth stage.
    Looks up days_to_harvest from the growth_phases table.
    Falls back to size-based lookup if stage match returns no result.
    """
    phase = db.query(GrowthPhase).filter(GrowthPhase.stage == growth_stage).first()

    if phase is None:
        phase = (
            db.query(GrowthPhase)
            .filter(GrowthPhase.size_min_cm <= size_cm, GrowthPhase.size_max_cm > size_cm)
            .first()
        )

    if phase is None:
        # Size is beyond all known phases — treat as pre-harvest
        days = 14
    else:
        days = phase.days_to_harvest

    harvest_date = date.today() + timedelta(days=days)
    return harvest_date, days
