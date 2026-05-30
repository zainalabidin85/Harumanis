"""Add address column to users table."""
from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('users', sa.Column('address', sa.Text(), nullable=True))


def downgrade():
    op.drop_column('users', 'address')
