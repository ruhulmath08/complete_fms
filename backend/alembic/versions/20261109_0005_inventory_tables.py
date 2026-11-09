"""inventory items and stock updates tables

Revision ID: 20261109_0005
Revises: 20261109_0004
Create Date: 2026-11-09T12:41:00Z

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "20261109_0005"
down_revision: Union[str, None] = "20261109_0004"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "inventory_items",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("category", sa.String(length=64), nullable=False),
        sa.Column("quantity", sa.Numeric(12, 3), nullable=False),
        sa.Column("unit", sa.String(length=32), nullable=False),
        sa.Column("price_per_unit", sa.Numeric(12, 2), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
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
    op.create_index(
        "ix_inventory_items_owner_id", "inventory_items", ["owner_id"], unique=False
    )
    op.create_index(
        "ix_inventory_items_owner_archived",
        "inventory_items",
        ["owner_id", "is_archived"],
        unique=False,
    )

    op.create_table(
        "stock_updates",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("inventory_item_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("occurred_at", sa.Date(), nullable=False),
        sa.Column("change_type", sa.String(length=16), nullable=False),
        sa.Column("quantity_change", sa.Numeric(12, 3), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
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
            ["inventory_item_id"], ["inventory_items.id"], ondelete="CASCADE"
        ),
        sa.ForeignKeyConstraint(["owner_id"], ["owners.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_stock_updates_inventory_item_id",
        "stock_updates",
        ["inventory_item_id"],
        unique=False,
    )
    op.create_index(
        "ix_stock_updates_owner_id", "stock_updates", ["owner_id"], unique=False
    )
    op.create_index(
        "ix_stock_updates_item_occurred",
        "stock_updates",
        ["inventory_item_id", "occurred_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("ix_stock_updates_item_occurred", table_name="stock_updates")
    op.drop_index("ix_stock_updates_owner_id", table_name="stock_updates")
    op.drop_index("ix_stock_updates_inventory_item_id", table_name="stock_updates")
    op.drop_table("stock_updates")
    op.drop_index("ix_inventory_items_owner_archived", table_name="inventory_items")
    op.drop_index("ix_inventory_items_owner_id", table_name="inventory_items")
    op.drop_table("inventory_items")
