"""add confirmed_at, harvested_at, delivered_at, cancelled_at to orders

Revision ID: 013
Revises: 012
Create Date: 2026-05-28
"""
from alembic import op
import sqlalchemy as sa

revision = "013"
down_revision = "012"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('orders', sa.Column('confirmed_at', sa.DateTime(), nullable=True))
    op.add_column('orders', sa.Column('harvested_at', sa.DateTime(), nullable=True))
    op.add_column('orders', sa.Column('delivered_at', sa.DateTime(), nullable=True))
    op.add_column('orders', sa.Column('cancelled_at', sa.DateTime(), nullable=True))


def downgrade():
    op.drop_column('orders', 'cancelled_at')
    op.drop_column('orders', 'delivered_at')
    op.drop_column('orders', 'harvested_at')
    op.drop_column('orders', 'confirmed_at')
