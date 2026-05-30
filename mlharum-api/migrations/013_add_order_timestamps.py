"""Add confirmed_at, harvested_at, delivered_at, cancelled_at to orders."""
from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column("orders", sa.Column("confirmed_at",  sa.DateTime(), nullable=True))
    op.add_column("orders", sa.Column("harvested_at",  sa.DateTime(), nullable=True))
    op.add_column("orders", sa.Column("delivered_at",  sa.DateTime(), nullable=True))
    op.add_column("orders", sa.Column("cancelled_at",  sa.DateTime(), nullable=True))


def downgrade():
    op.drop_column("orders", "cancelled_at")
    op.drop_column("orders", "delivered_at")
    op.drop_column("orders", "harvested_at")
    op.drop_column("orders", "confirmed_at")
