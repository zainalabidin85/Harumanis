"""update growth_phases to DOA's 3-stage model

Revision ID: 017
Revises: 016
Create Date: 2026-07-02
"""
from alembic import op
from sqlalchemy.sql import table, column
import sqlalchemy as sa

revision = "017"
down_revision = "016"
branch_labels = None
depends_on = None

growth_phases = table(
    "growth_phases",
    column("stage", sa.Integer),
    column("label", sa.String),
    column("size_min_cm", sa.Numeric),
    column("size_max_cm", sa.Numeric),
    column("days_to_harvest", sa.Integer),
)


def upgrade() -> None:
    op.execute("DELETE FROM growth_phases WHERE stage IN (1, 2, 3, 4)")
    op.bulk_insert(
        growth_phases,
        [
            {"stage": 1, "label": "Early",       "size_min_cm": 0.0, "size_max_cm": 4.0,  "days_to_harvest": 90},
            {"stage": 2, "label": "Bagging",      "size_min_cm": 4.0, "size_max_cm": 4.5,  "days_to_harvest": 56},
            {"stage": 3, "label": "Pre-harvest",  "size_min_cm": 4.5, "size_max_cm": None, "days_to_harvest": 49},
        ],
    )

    # Recompute growth_stage on already-recorded fruits from their stored size_cm,
    # since the stage boundaries changed. harvest_date is left untouched — it was
    # already communicated to the farmer at scan time.
    op.execute(
        """
        UPDATE fruits SET growth_stage = CASE
            WHEN size_cm < 4.0 THEN 1
            WHEN size_cm < 4.5 THEN 2
            ELSE 3
        END
        """
    )


def downgrade() -> None:
    op.execute("DELETE FROM growth_phases WHERE stage IN (1, 2, 3)")
    op.bulk_insert(
        growth_phases,
        [
            {"stage": 1, "label": "Early",       "size_min_cm": 1.0, "size_max_cm": 2.5,  "days_to_harvest": 90},
            {"stage": 2, "label": "Mid",          "size_min_cm": 2.5, "size_max_cm": 5.0,  "days_to_harvest": 56},
            {"stage": 3, "label": "Late",         "size_min_cm": 5.0, "size_max_cm": 8.0,  "days_to_harvest": 30},
            {"stage": 4, "label": "Pre-harvest",  "size_min_cm": 8.0, "size_max_cm": 12.0, "days_to_harvest": 14},
        ],
    )
