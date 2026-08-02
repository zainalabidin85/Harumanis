"""016 add season to fruits"""
from alembic import op
import sqlalchemy as sa
from datetime import datetime

revision = '016'
down_revision = '015'
branch_labels = None
depends_on = None

current_year = datetime.now().year


def upgrade():
    op.add_column('fruits', sa.Column('season', sa.Integer(), nullable=False, server_default=str(current_year)))


def downgrade():
    op.drop_column('fruits', 'season')
