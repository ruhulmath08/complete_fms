"""add cow_feedings.unit_cost

Revision ID: 20261112_0008
Revises: 20261111_0007
Create Date: 2026-11-12T07:52:07Z

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "20261112_0008"
down_revision: Union[str, None] = "20261111_0007"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "cow_feedings",
        sa.Column("unit_cost", sa.Numeric(12, 2), nullable=True),
    )
    op.execute("UPDATE cow_feedings SET unit_cost = 0 WHERE unit_cost IS NULL")
    op.alter_column(
        "cow_feedings",
        "unit_cost",
        existing_type=sa.Numeric(12, 2),
        nullable=False,
    )


def downgrade() -> None:
    op.drop_column("cow_feedings", "unit_cost")
