"""add farm_images table

Revision ID: 008
Revises: 007
Create Date: 2026-05-21
"""
from alembic import op
import sqlalchemy as sa

revision = "008"
down_revision = "007"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "farm_images",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("farm_id", sa.Integer(), sa.ForeignKey("farms.id", ondelete="CASCADE"), nullable=False),
        sa.Column("filename", sa.String(255), nullable=False),
        sa.Column("caption", sa.String(200), nullable=True),
        sa.Column("uploaded_at", sa.DateTime(), server_default=sa.func.now()),
    )
    op.create_index("ix_farm_images_farm_id", "farm_images", ["farm_id"])


def downgrade() -> None:
    op.drop_index("ix_farm_images_farm_id", "farm_images")
    op.drop_table("farm_images")
