"""add reference type to detections

Revision ID: 025
Revises: 024
Create Date: 2026-10-20
"""
from alembic import op
import sqlalchemy as sa

revision = "025"
down_revision = "024"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Which size reference the scan used: circle / square sticker or hand. NULL = hand scan from before 025.
    op.add_column("detections", sa.Column("reference_type", sa.String(10), nullable=True))


def downgrade() -> None:
    op.drop_column("detections", "reference_type")
