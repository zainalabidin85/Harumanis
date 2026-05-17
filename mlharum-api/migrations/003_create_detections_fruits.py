"""create detections and fruits tables

Revision ID: 003
Revises: 002
Create Date: 2026-05-17
"""
from alembic import op
import sqlalchemy as sa

revision = "003"
down_revision = "002"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "detections",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("tree_id", sa.Integer(), sa.ForeignKey("trees.id", ondelete="CASCADE"), nullable=False),
        sa.Column("image_path", sa.String(500)),
        sa.Column("mango_count", sa.Integer(), default=0),
        sa.Column("knuckle_width_px", sa.Numeric(6, 2)),
        sa.Column("detected_at", sa.DateTime(), server_default=sa.func.now()),
    )

    op.create_table(
        "fruits",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("detection_id", sa.Integer(), sa.ForeignKey("detections.id", ondelete="CASCADE"), nullable=False),
        sa.Column("tree_id", sa.Integer(), sa.ForeignKey("trees.id"), nullable=False),
        sa.Column("label", sa.String(30), nullable=False),
        sa.Column("size_cm", sa.Numeric(5, 2)),
        sa.Column("growth_stage", sa.SmallInteger()),
        sa.Column("harvest_date", sa.Date()),
        sa.Column("bbox_x", sa.Numeric(6, 2)),
        sa.Column("bbox_y", sa.Numeric(6, 2)),
        sa.Column("bbox_w", sa.Numeric(6, 2)),
        sa.Column("bbox_h", sa.Numeric(6, 2)),
        sa.Column("is_harvested", sa.Boolean(), default=False),
        sa.Column("harvested_at", sa.DateTime()),
        sa.Column("created_at", sa.DateTime(), server_default=sa.func.now()),
    )

    op.create_index("ix_fruits_tree_id", "fruits", ["tree_id"])
    op.create_index("ix_fruits_harvest_date", "fruits", ["harvest_date"])


def downgrade() -> None:
    op.drop_index("ix_fruits_harvest_date", table_name="fruits")
    op.drop_index("ix_fruits_tree_id", table_name="fruits")
    op.drop_table("fruits")
    op.drop_table("detections")
