"""add harvest_reminder_sent_at to fruits

Revision ID: 021
Revises: 020
Create Date: 2026-08-02
"""
from alembic import op
import sqlalchemy as sa

revision = "021"
down_revision = "020"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("fruits", sa.Column("harvest_reminder_sent_at", sa.DateTime(), nullable=True))


def downgrade() -> None:
    op.drop_column("fruits", "harvest_reminder_sent_at")
