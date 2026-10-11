"""add knuckle span to users and reference span to detections

Revision ID: 023
Revises: 022
Create Date: 2026-10-11
"""
from alembic import op
import sqlalchemy as sa

revision = "023"
down_revision = "022"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # NULL = user has not measured their hand; sizing falls back to the average span.
    op.add_column("users", sa.Column("knuckle_span_cm", sa.Numeric(4, 2), nullable=True))
    # Span actually used for this scan. NULL = scans from before this column existed (average span).
    op.add_column("detections", sa.Column("reference_span_cm", sa.Numeric(4, 2), nullable=True))


def downgrade() -> None:
    op.drop_column("detections", "reference_span_cm")
    op.drop_column("users", "knuckle_span_cm")
