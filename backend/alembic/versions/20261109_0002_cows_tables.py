"""cows milk and feeding tables

Revision ID: 20261109_0002
Revises: 20261109_0001
Create Date: 2026-11-09T10:36:09Z

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "20261109_0002"
down_revision: Union[str, None] = "20261109_0001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "cows",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("tag_number", sa.String(length=64), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=True),
        sa.Column("breed", sa.String(length=128), nullable=True),
        sa.Column("date_of_birth", sa.Date(), nullable=True),
        sa.Column("purpose", sa.String(length=16), nullable=False),
        sa.Column("gender", sa.String(length=16), nullable=False),
        sa.Column("color", sa.String(length=64), nullable=True),
        sa.Column("weight", sa.Numeric(12, 3), nullable=True),
        sa.Column("age", sa.Integer(), nullable=True),
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
    op.create_index("ix_cows_owner_id", "cows", ["owner_id"], unique=False)
    op.create_index("ix_cows_owner_archived", "cows", ["owner_id", "is_archived"], unique=False)
    op.create_index(
        "uq_cows_owner_tag_active",
        "cows",
        ["owner_id", "tag_number"],
        unique=True,
        postgresql_where=sa.text("is_archived = false"),
    )

    op.create_table(
        "milk_productions",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("cow_id", postgresql.UUID(as_uuid=True), nullable=False),
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
        sa.ForeignKeyConstraint(["cow_id"], ["cows.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["owner_id"], ["owners.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_milk_productions_cow_id", "milk_productions", ["cow_id"], unique=False)
    op.create_index("ix_milk_productions_owner_id", "milk_productions", ["owner_id"], unique=False)
    op.create_index(
        "ix_milk_productions_cow_produced",
        "milk_productions",
        ["cow_id", "produced_at"],
        unique=False,
    )

    op.create_table(
        "cow_feedings",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("cow_id", postgresql.UUID(as_uuid=True), nullable=False),
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
        sa.ForeignKeyConstraint(["cow_id"], ["cows.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["owner_id"], ["owners.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_cow_feedings_cow_id", "cow_feedings", ["cow_id"], unique=False)
    op.create_index("ix_cow_feedings_owner_id", "cow_feedings", ["owner_id"], unique=False)
    op.create_index(
        "ix_cow_feedings_cow_fed",
        "cow_feedings",
        ["cow_id", "fed_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("ix_cow_feedings_cow_fed", table_name="cow_feedings")
    op.drop_index("ix_cow_feedings_owner_id", table_name="cow_feedings")
    op.drop_index("ix_cow_feedings_cow_id", table_name="cow_feedings")
    op.drop_table("cow_feedings")

    op.drop_index("ix_milk_productions_cow_produced", table_name="milk_productions")
    op.drop_index("ix_milk_productions_owner_id", table_name="milk_productions")
    op.drop_index("ix_milk_productions_cow_id", table_name="milk_productions")
    op.drop_table("milk_productions")

    op.drop_index("uq_cows_owner_tag_active", table_name="cows")
    op.drop_index("ix_cows_owner_archived", table_name="cows")
    op.drop_index("ix_cows_owner_id", table_name="cows")
    op.drop_table("cows")
