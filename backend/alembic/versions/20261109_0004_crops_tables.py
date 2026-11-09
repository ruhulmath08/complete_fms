"""crop names cycles expenses and harvests tables

Revision ID: 20261109_0004
Revises: 20261109_0003
Create Date: 2026-11-09T12:07:28Z

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "20261109_0004"
down_revision: Union[str, None] = "20261109_0003"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "crop_names",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
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
    op.create_index("ix_crop_names_owner_id", "crop_names", ["owner_id"], unique=False)
    op.create_index(
        "ix_crop_names_owner_archived",
        "crop_names",
        ["owner_id", "is_archived"],
        unique=False,
    )
    op.create_index(
        "uq_crop_names_owner_name_active",
        "crop_names",
        ["owner_id", "name"],
        unique=True,
        postgresql_where=sa.text("is_archived = false"),
    )

    op.create_table(
        "crop_cycles",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("crop_name_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("plot_name", sa.String(length=255), nullable=True),
        sa.Column("area", sa.Numeric(12, 3), nullable=True),
        sa.Column("location", sa.String(length=255), nullable=True),
        sa.Column("planted_at", sa.Date(), nullable=False),
        sa.Column("expected_harvest_at", sa.Date(), nullable=True),
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
        sa.ForeignKeyConstraint(["crop_name_id"], ["crop_names.id"], ondelete="RESTRICT"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_crop_cycles_owner_id", "crop_cycles", ["owner_id"], unique=False)
    op.create_index(
        "ix_crop_cycles_crop_name_id", "crop_cycles", ["crop_name_id"], unique=False
    )
    op.create_index(
        "ix_crop_cycles_owner_archived",
        "crop_cycles",
        ["owner_id", "is_archived"],
        unique=False,
    )

    op.create_table(
        "crop_expenses",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("crop_cycle_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("spent_at", sa.Date(), nullable=False),
        sa.Column("category", sa.String(length=64), nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
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
        sa.ForeignKeyConstraint(["crop_cycle_id"], ["crop_cycles.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["owner_id"], ["owners.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_crop_expenses_crop_cycle_id", "crop_expenses", ["crop_cycle_id"], unique=False
    )
    op.create_index(
        "ix_crop_expenses_owner_id", "crop_expenses", ["owner_id"], unique=False
    )
    op.create_index(
        "ix_crop_expenses_cycle_spent",
        "crop_expenses",
        ["crop_cycle_id", "spent_at"],
        unique=False,
    )

    op.create_table(
        "harvests",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("crop_cycle_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("harvested_at", sa.Date(), nullable=False),
        sa.Column("quantity", sa.Numeric(12, 3), nullable=False),
        sa.Column("unit", sa.String(length=32), nullable=False),
        sa.Column("sale_amount", sa.Numeric(12, 2), nullable=True),
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
        sa.ForeignKeyConstraint(["crop_cycle_id"], ["crop_cycles.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["owner_id"], ["owners.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_harvests_crop_cycle_id", "harvests", ["crop_cycle_id"], unique=False
    )
    op.create_index("ix_harvests_owner_id", "harvests", ["owner_id"], unique=False)
    op.create_index(
        "ix_harvests_cycle_harvested",
        "harvests",
        ["crop_cycle_id", "harvested_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("ix_harvests_cycle_harvested", table_name="harvests")
    op.drop_index("ix_harvests_owner_id", table_name="harvests")
    op.drop_index("ix_harvests_crop_cycle_id", table_name="harvests")
    op.drop_table("harvests")

    op.drop_index("ix_crop_expenses_cycle_spent", table_name="crop_expenses")
    op.drop_index("ix_crop_expenses_owner_id", table_name="crop_expenses")
    op.drop_index("ix_crop_expenses_crop_cycle_id", table_name="crop_expenses")
    op.drop_table("crop_expenses")

    op.drop_index("ix_crop_cycles_owner_archived", table_name="crop_cycles")
    op.drop_index("ix_crop_cycles_crop_name_id", table_name="crop_cycles")
    op.drop_index("ix_crop_cycles_owner_id", table_name="crop_cycles")
    op.drop_table("crop_cycles")

    op.drop_index("uq_crop_names_owner_name_active", table_name="crop_names")
    op.drop_index("ix_crop_names_owner_archived", table_name="crop_names")
    op.drop_index("ix_crop_names_owner_id", table_name="crop_names")
    op.drop_table("crop_names")
