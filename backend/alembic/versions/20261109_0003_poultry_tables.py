"""poultry groups feedings and egg productions tables

Revision ID: 20261109_0003
Revises: 20261109_0002
Create Date: 2026-11-09T11:29:47Z

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "20261109_0003"
down_revision: Union[str, None] = "20261109_0002"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "poultry_groups",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("poultry_type", sa.String(length=16), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("bird_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("date_acquired", sa.Date(), nullable=True),
        sa.Column("acquired_by", sa.String(length=32), nullable=False),
        sa.Column("purchase_date", sa.Date(), nullable=True),
        sa.Column("purchase_price", sa.Numeric(12, 2), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("is_archived", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["owner_id"], ["owners.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_poultry_groups_owner_id", "poultry_groups", ["owner_id"], unique=False)
    op.create_index(
        "ix_poultry_groups_owner_archived",
        "poultry_groups",
        ["owner_id", "is_archived"],
        unique=False,
    )

    op.create_table(
        "poultry_feedings",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("poultry_group_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("fed_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("feed_name", sa.String(length=255), nullable=False),
        sa.Column("quantity", sa.Numeric(12, 3), nullable=False),
        sa.Column("unit", sa.String(length=32), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["poultry_group_id"], ["poultry_groups.id"], ondelete="CASCADE"
        ),
        sa.ForeignKeyConstraint(["owner_id"], ["owners.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_poultry_feedings_poultry_group_id",
        "poultry_feedings",
        ["poultry_group_id"],
        unique=False,
    )
    op.create_index(
        "ix_poultry_feedings_owner_id", "poultry_feedings", ["owner_id"], unique=False
    )
    op.create_index(
        "ix_poultry_feedings_group_fed",
        "poultry_feedings",
        ["poultry_group_id", "fed_at"],
        unique=False,
    )

    op.create_table(
        "egg_productions",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("poultry_group_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("produced_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("quantity", sa.Numeric(12, 3), nullable=False),
        sa.Column("unit", sa.String(length=32), nullable=False),
        sa.Column("price_per_unit", sa.Numeric(12, 2), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["poultry_group_id"], ["poultry_groups.id"], ondelete="CASCADE"
        ),
        sa.ForeignKeyConstraint(["owner_id"], ["owners.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_egg_productions_poultry_group_id",
        "egg_productions",
        ["poultry_group_id"],
        unique=False,
    )
    op.create_index(
        "ix_egg_productions_owner_id", "egg_productions", ["owner_id"], unique=False
    )
    op.create_index(
        "ix_egg_productions_group_produced",
        "egg_productions",
        ["poultry_group_id", "produced_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("ix_egg_productions_group_produced", table_name="egg_productions")
    op.drop_index("ix_egg_productions_owner_id", table_name="egg_productions")
    op.drop_index("ix_egg_productions_poultry_group_id", table_name="egg_productions")
    op.drop_table("egg_productions")

    op.drop_index("ix_poultry_feedings_group_fed", table_name="poultry_feedings")
    op.drop_index("ix_poultry_feedings_owner_id", table_name="poultry_feedings")
    op.drop_index(
        "ix_poultry_feedings_poultry_group_id", table_name="poultry_feedings"
    )
    op.drop_table("poultry_feedings")

    op.drop_index("ix_poultry_groups_owner_archived", table_name="poultry_groups")
    op.drop_index("ix_poultry_groups_owner_id", table_name="poultry_groups")
    op.drop_table("poultry_groups")
