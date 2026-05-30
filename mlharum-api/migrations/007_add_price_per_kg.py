"""add price_per_kg to farms

Revision ID: 007
Revises: 006
Create Date: 2026-05-21
"""
from alembic import op
import sqlalchemy as sa

revision = "007"
down_revision = "006"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("farms", sa.Column("price_per_kg", sa.Numeric(10, 2), nullable=True))


def downgrade() -> None:
    op.drop_column("farms", "price_per_kg")
