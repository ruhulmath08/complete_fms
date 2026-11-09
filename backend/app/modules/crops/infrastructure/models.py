from __future__ import annotations

import uuid
from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Index,
    Numeric,
    String,
    Text,
    Uuid,
    func,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class CropNameModel(Base):
    __tablename__ = "crop_names"
    __table_args__ = (
        Index(
            "uq_crop_names_owner_name_active",
            "owner_id",
            "name",
            unique=True,
            postgresql_where=text("is_archived = false"),
            sqlite_where=text("is_archived = 0"),
        ),
        Index("ix_crop_names_owner_archived", "owner_id", "is_archived"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4
    )
    owner_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("owners.id", ondelete="CASCADE"), nullable=False, index=True
    )
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_archived: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )


class CropCycleModel(Base):
    __tablename__ = "crop_cycles"
    __table_args__ = (
        Index("ix_crop_cycles_owner_archived", "owner_id", "is_archived"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4
    )
    owner_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("owners.id", ondelete="CASCADE"), nullable=False, index=True
    )
    crop_name_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("crop_names.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    plot_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    area: Mapped[Decimal | None] = mapped_column(Numeric(12, 3), nullable=True)
    location: Mapped[str | None] = mapped_column(String(255), nullable=True)
    planted_at: Mapped[date] = mapped_column(Date, nullable=False)
    expected_harvest_at: Mapped[date | None] = mapped_column(Date, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_archived: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )


class CropExpenseModel(Base):
    __tablename__ = "crop_expenses"
    __table_args__ = (
        Index("ix_crop_expenses_cycle_spent", "crop_cycle_id", "spent_at"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4
    )
    crop_cycle_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("crop_cycles.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    owner_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("owners.id", ondelete="CASCADE"), nullable=False, index=True
    )
    spent_at: Mapped[date] = mapped_column(Date, nullable=False)
    category: Mapped[str] = mapped_column(String(64), nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )


class HarvestModel(Base):
    __tablename__ = "harvests"
    __table_args__ = (
        Index("ix_harvests_cycle_harvested", "crop_cycle_id", "harvested_at"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, default=uuid.uuid4
    )
    crop_cycle_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("crop_cycles.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    owner_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("owners.id", ondelete="CASCADE"), nullable=False, index=True
    )
    harvested_at: Mapped[date] = mapped_column(Date, nullable=False)
    quantity: Mapped[Decimal] = mapped_column(Numeric(12, 3), nullable=False)
    unit: Mapped[str] = mapped_column(String(32), nullable=False)
    sale_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
