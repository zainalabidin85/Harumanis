"""add buyer support — role on users, whatsapp on users, is_public on farms, orders table

Revision ID: 006
Revises: 005
Create Date: 2026-05-21
"""
from alembic import op
import sqlalchemy as sa

revision = "006"
down_revision = "005"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("role", sa.String(20), nullable=False, server_default="farmer"))
    op.add_column("users", sa.Column("whatsapp", sa.String(20), nullable=True))

    op.add_column("farms", sa.Column("is_public", sa.Boolean(), nullable=False, server_default="false"))

    op.create_table(
        "orders",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("buyer_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("farm_id", sa.Integer(), sa.ForeignKey("farms.id", ondelete="CASCADE"), nullable=False),
        sa.Column("quantity_kg", sa.Numeric(7, 2), nullable=False),
        sa.Column("price_per_kg", sa.Numeric(7, 2), nullable=False),
        sa.Column("total_price", sa.Numeric(9, 2), nullable=False),
        sa.Column("target_harvest_date", sa.Date(), nullable=True),
        sa.Column("notes", sa.String(500), nullable=True),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("billplz_bill_id", sa.String(100), nullable=True),
        sa.Column("billplz_paid", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("paid_at", sa.DateTime(), nullable=True),
        sa.Column("created_at", sa.DateTime(), server_default=sa.func.now()),
    )
    op.create_index("ix_orders_buyer_id", "orders", ["buyer_id"])
    op.create_index("ix_orders_farm_id", "orders", ["farm_id"])
    op.create_index("ix_orders_status", "orders", ["status"])


def downgrade() -> None:
    op.drop_index("ix_orders_status", table_name="orders")
    op.drop_index("ix_orders_farm_id", table_name="orders")
    op.drop_index("ix_orders_buyer_id", table_name="orders")
    op.drop_table("orders")
    op.drop_column("farms", "is_public")
    op.drop_column("users", "whatsapp")
    op.drop_column("users", "role")
