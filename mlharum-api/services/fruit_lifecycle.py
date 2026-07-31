from datetime import datetime
from sqlalchemy.orm import Session
from models.fruit import Fruit


def auto_abort_stale_fruits(db: Session) -> None:
    """Mark fruits left over from a prior season (never harvested or aborted) as lost.

    Season has no explicit rollover job — it's derived from datetime.now().year
    wherever it's needed. A fruit whose season is behind the current year was
    never closed out during its own season, so it's treated as a loss now.
    """
    current_season = datetime.now().year
    db.query(Fruit).filter(
        Fruit.season < current_season,
        Fruit.is_harvested == False,
        Fruit.is_aborted == False,
    ).update(
        {
            Fruit.is_aborted: True,
            Fruit.abort_reason: "Unharvested — season ended",
            Fruit.aborted_at: datetime.utcnow(),
        },
        synchronize_session=False,
    )
    db.commit()
