"""add farmer bank details to users table

Revision ID: 009
Revises: 008
Create Date: 2026-05-25
"""
from alembic import op
import sqlalchemy as sa

revision = "009"
down_revision = "008"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('users', sa.Column('bank_name',           sa.String(100), nullable=True))
    op.add_column('users', sa.Column('bank_account_number', sa.String(50),  nullable=True))
    op.add_column('users', sa.Column('bank_account_name',   sa.String(100), nullable=True))


def downgrade():
    op.drop_column('users', 'bank_account_name')
    op.drop_column('users', 'bank_account_number')
    op.drop_column('users', 'bank_name')
