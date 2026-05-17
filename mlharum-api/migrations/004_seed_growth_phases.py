"""seed growth_phases with Harumanis growth data

Revision ID: 004
Revises: 003
Create Date: 2026-05-17
"""
from alembic import op
from sqlalchemy.sql import table, column
import sqlalchemy as sa

revision = "004"
down_revision = "003"
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
    op.bulk_insert(
        growth_phases,
        [
            {"stage": 1, "label": "Early",       "size_min_cm": 1.0, "size_max_cm": 2.5,  "days_to_harvest": 90},
            {"stage": 2, "label": "Mid",          "size_min_cm": 2.5, "size_max_cm": 5.0,  "days_to_harvest": 60},
            {"stage": 3, "label": "Late",         "size_min_cm": 5.0, "size_max_cm": 8.0,  "days_to_harvest": 30},
            {"stage": 4, "label": "Pre-harvest",  "size_min_cm": 8.0, "size_max_cm": 12.0, "days_to_harvest": 14},
        ],
    )


def downgrade() -> None:
    op.execute("DELETE FROM growth_phases WHERE stage IN (1, 2, 3, 4)")
