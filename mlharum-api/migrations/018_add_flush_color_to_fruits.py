"""add flush_color to fruits

Revision ID: 018
Revises: 017
Create Date: 2026-07-02
"""
from alembic import op
import sqlalchemy as sa

revision = "018"
down_revision = "017"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("fruits", sa.Column("flush_color", sa.String(20), nullable=True))


def downgrade() -> None:
    op.drop_column("fruits", "flush_color")
