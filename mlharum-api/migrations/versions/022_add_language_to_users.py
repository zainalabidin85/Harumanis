"""add language to users

Revision ID: 022
Revises: 021
Create Date: 2026-10-05
"""
from alembic import op
import sqlalchemy as sa

revision = "022"
down_revision = "021"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # NULL = never reported by the app; treated as English everywhere.
    op.add_column("users", sa.Column("language", sa.String(length=5), nullable=True))


def downgrade() -> None:
    op.drop_column("users", "language")
