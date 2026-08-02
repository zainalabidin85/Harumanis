"""add password reset OTP fields to users

Revision ID: 005
Revises: 004
Create Date: 2026-05-18
"""
from alembic import op
import sqlalchemy as sa

revision = "005"
down_revision = "004"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("reset_otp_hash", sa.String(255), nullable=True))
    op.add_column("users", sa.Column("reset_otp_expires", sa.DateTime(), nullable=True))


def downgrade() -> None:
    op.drop_column("users", "reset_otp_expires")
    op.drop_column("users", "reset_otp_hash")
