"""add farm_settings.timezone

Revision ID: 20261113_0009
Revises: 20261112_0008
Create Date: 2026-11-13T07:15:00Z

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "20261113_0009"
down_revision: Union[str, None] = "20261112_0008"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "farm_settings",
        sa.Column("timezone", sa.String(length=64), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("farm_settings", "timezone")
