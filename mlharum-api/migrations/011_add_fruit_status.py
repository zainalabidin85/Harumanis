"""add abort fields to fruits

Revision ID: 011
Revises: 010
Create Date: 2026-05-25
"""
from alembic import op
import sqlalchemy as sa

revision = "011"
down_revision = "010"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('fruits', sa.Column('is_aborted',  sa.Boolean(),     nullable=False, server_default='false'))
    op.add_column('fruits', sa.Column('abort_reason', sa.String(200),  nullable=True))
    op.add_column('fruits', sa.Column('aborted_at',   sa.DateTime(),   nullable=True))


def downgrade():
    op.drop_column('fruits', 'aborted_at')
    op.drop_column('fruits', 'abort_reason')
    op.drop_column('fruits', 'is_aborted')
