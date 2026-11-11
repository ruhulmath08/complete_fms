"""add cows.image_path

Revision ID: 20261111_0007
Revises: 20261109_0006
Create Date: 2026-11-11T18:14:48Z

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "20261111_0007"
down_revision: Union[str, None] = "20261109_0006"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("cows", sa.Column("image_path", sa.Text(), nullable=True))


def downgrade() -> None:
    op.drop_column("cows", "image_path")
