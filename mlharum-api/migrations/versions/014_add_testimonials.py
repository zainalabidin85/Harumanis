"""Add testimonials table for buyer reviews on farms.

Revision ID: 014
Revises: 013
Create Date: 2026-05-30
"""
from alembic import op
import sqlalchemy as sa

revision = "014"
down_revision = "013"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "testimonials",
        sa.Column("id",         sa.Integer(),      primary_key=True),
        sa.Column("farm_id",    sa.Integer(),      sa.ForeignKey("farms.id",  ondelete="CASCADE"), nullable=False),
        sa.Column("buyer_id",   sa.Integer(),      sa.ForeignKey("users.id",  ondelete="CASCADE"), nullable=False),
        sa.Column("rating",     sa.SmallInteger(), nullable=False),
        sa.Column("comment",    sa.Text(),         nullable=True),
        sa.Column("created_at", sa.DateTime(),     server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(),     server_default=sa.func.now()),
    )
    op.create_index("ix_testimonials_farm_id", "testimonials", ["farm_id"])
    op.create_unique_constraint(
        "uq_testimonials_buyer_farm", "testimonials", ["buyer_id", "farm_id"]
    )


def downgrade():
    op.drop_constraint("uq_testimonials_buyer_farm", "testimonials", type_="unique")
    op.drop_index("ix_testimonials_farm_id", table_name="testimonials")
    op.drop_table("testimonials")
