"""rename billplz order columns to gateway-neutral names (move to ToyyibPay)

Revision ID: 024
Revises: 023
Create Date: 2026-10-17
"""
from alembic import op

revision = "024"
down_revision = "023"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.alter_column("orders", "billplz_bill_id", new_column_name="payment_bill_code")
    op.alter_column("orders", "billplz_paid", new_column_name="is_paid")
    # Billplz bill ids mean nothing to ToyyibPay; unpaid orders get a new bill on the next Pay Now.
    op.execute("UPDATE orders SET payment_bill_code = NULL WHERE is_paid = false")


def downgrade() -> None:
    op.alter_column("orders", "is_paid", new_column_name="billplz_paid")
    op.alter_column("orders", "payment_bill_code", new_column_name="billplz_bill_id")
