"""add admin support — is_suspended/is_verified on users, payout fields on orders, seed admin

Revision ID: 010
Revises: 009
Create Date: 2026-05-25
"""
from alembic import op
import sqlalchemy as sa

revision = "010"
down_revision = "009"
branch_labels = None
depends_on = None


def upgrade():
    # ── users ──────────────────────────────────────────────────────────────────
    op.add_column('users', sa.Column('is_suspended', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('users', sa.Column('is_verified',  sa.Boolean(), nullable=False, server_default='false'))

    # Seed zainal as admin
    op.execute("""
        UPDATE users
        SET role = 'admin', is_verified = true
        WHERE email = 'zainalabidin@unimap.edu.my'
    """)

    # ── orders ─────────────────────────────────────────────────────────────────
    op.add_column('orders', sa.Column('payout_status',    sa.String(20),  nullable=True))
    op.add_column('orders', sa.Column('payout_reference', sa.String(100), nullable=True))
    op.add_column('orders', sa.Column('payout_at',        sa.DateTime(),  nullable=True))

    # Mark all existing delivered+paid orders as payout pending
    op.execute("""
        UPDATE orders
        SET payout_status = 'pending'
        WHERE status = 'delivered' AND billplz_paid = true AND payout_status IS NULL
    """)


def downgrade():
    op.drop_column('orders', 'payout_at')
    op.drop_column('orders', 'payout_reference')
    op.drop_column('orders', 'payout_status')
    op.drop_column('users', 'is_verified')
    op.drop_column('users', 'is_suspended')
