"""015 add ready_in_days to farms"""
from alembic import op
import sqlalchemy as sa

revision = '015'
down_revision = '014'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('farms', sa.Column('ready_in_days', sa.Integer(), nullable=False, server_default='4'))


def downgrade():
    op.drop_column('farms', 'ready_in_days')
