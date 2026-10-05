import logging
from collections import defaultdict
from datetime import date, datetime, timedelta

from sqlalchemy.orm import Session

from models.fruit import Fruit
from models.tree import Tree
from models.farm import Farm
from models.user import User
from services import push_service
from services.i18n import harvest_reminder_text

logger = logging.getLogger(__name__)


def run_harvest_reminder_check(db: Session) -> None:
    """Notify farmers once per fruit when its predicted harvest_date is imminent.

    Only in-process trigger for this job is APScheduler in main.py — running it
    across multiple uvicorn workers would double-notify, see main.py comment.
    """
    cutoff = date.today() + timedelta(days=1)
    due_fruits = (
        db.query(Fruit, Farm.user_id)
        .join(Tree, Tree.id == Fruit.tree_id)
        .join(Farm, Farm.id == Tree.farm_id)
        .filter(
            Fruit.is_harvested.is_(False),
            Fruit.is_aborted.is_(False),
            Fruit.harvest_reminder_sent_at.is_(None),
            Fruit.harvest_date.isnot(None),
            Fruit.harvest_date <= cutoff,
        )
        .all()
    )

    if not due_fruits:
        return

    by_owner: dict[int, list[Fruit]] = defaultdict(list)
    for fruit, owner_id in due_fruits:
        by_owner[owner_id].append(fruit)

    languages = dict(
        db.query(User.id, User.language).filter(User.id.in_(list(by_owner.keys()))).all()
    )

    for owner_id, fruits in by_owner.items():
        title, body = harvest_reminder_text(
            languages.get(owner_id), [f.label for f in fruits]
        )
        push_service.send_to_user(
            db,
            owner_id,
            title=title,
            body=body,
            data={"type": "harvest_reminder"},
        )

    for fruit, _ in due_fruits:
        fruit.harvest_reminder_sent_at = datetime.utcnow()
    db.commit()
    logger.info("Harvest reminder job: notified %d owner(s) across %d fruit(s).", len(by_owner), len(due_fruits))
