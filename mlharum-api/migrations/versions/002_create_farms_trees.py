"""create farms, growth_phases and trees tables

Revision ID: 002
Revises: 001
Create Date: 2026-05-17
"""
from alembic import op
import sqlalchemy as sa

revision = "002"
down_revision = "001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "farms",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("location", sa.String(255)),
        sa.Column("gps_lat", sa.Numeric(9, 6)),
        sa.Column("gps_lng", sa.Numeric(9, 6)),
        sa.Column("total_trees", sa.Integer(), default=0),
        sa.Column("created_at", sa.DateTime(), server_default=sa.func.now()),
    )

    op.create_table(
        "growth_phases",
        sa.Column("stage", sa.Integer(), primary_key=True),
        sa.Column("label", sa.String(50)),
        sa.Column("size_min_cm", sa.Numeric(4, 2)),
        sa.Column("size_max_cm", sa.Numeric(4, 2)),
        sa.Column("days_to_harvest", sa.Integer()),
    )

    op.create_table(
        "trees",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("farm_id", sa.Integer(), sa.ForeignKey("farms.id", ondelete="CASCADE"), nullable=False),
        sa.Column("tree_number", sa.String(20), nullable=False),
        sa.Column("gps_lat", sa.Numeric(9, 6)),
        sa.Column("gps_lng", sa.Numeric(9, 6)),
        sa.Column("notes", sa.Text()),
        sa.Column("created_at", sa.DateTime(), server_default=sa.func.now()),
        sa.UniqueConstraint("farm_id", "tree_number", name="uq_farm_tree_number"),
    )


def downgrade() -> None:
    op.drop_table("trees")
    op.drop_table("growth_phases")
    op.drop_table("farms")
