import { useState, type FormEvent } from "react";
import {
  INVENTORY_CATEGORIES,
  type InventoryCategory,
  type InventoryItem,
  type InventoryItemCreateInput,
  type InventoryItemUpdateInput,
} from "../types";

type InventoryItemFormProps = {
  mode: "create" | "edit";
  initial?: InventoryItem;
  submitLabel: string;
  pending?: boolean;
  onSubmit: (
    input: InventoryItemCreateInput | InventoryItemUpdateInput,
  ) => void;
};

function emptyOrNull(value: string): string | null {
  const trimmed = value.trim();
  return trimmed ? trimmed : null;
}

export function InventoryItemForm({
  mode,
  initial,
  submitLabel,
  pending,
  onSubmit,
}: InventoryItemFormProps) {
  const [name, setName] = useState(initial?.name ?? "");
  const [category, setCategory] = useState<InventoryCategory>(
    initial?.category ?? "feed",
  );
  const [quantity, setQuantity] = useState(initial?.quantity ?? "0");
  const [unit, setUnit] = useState(initial?.unit ?? "kg");
  const [pricePerUnit, setPricePerUnit] = useState(
    initial?.price_per_unit ?? "0",
  );
  const [note, setNote] = useState(initial?.note ?? "");

  function handleSubmit(event: FormEvent) {
    event.preventDefault();
    if (mode === "create") {
      onSubmit({
        name: name.trim(),
        category,
        quantity,
        unit: unit.trim(),
        price_per_unit: pricePerUnit,
        note: emptyOrNull(note),
      } satisfies InventoryItemCreateInput);
      return;
    }
    onSubmit({
      name: name.trim(),
      category,
      unit: unit.trim(),
      price_per_unit: pricePerUnit,
      note: emptyOrNull(note),
    } satisfies InventoryItemUpdateInput);
  }

  return (
    <form className="form-stack" onSubmit={handleSubmit}>
      <div className="row-2">
        <div className="field">
          <label htmlFor="item_name">Name</label>
          <input
            id="item_name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>
        <div className="field">
          <label htmlFor="item_category">Category</label>
          <select
            id="item_category"
            value={category}
            onChange={(e) => setCategory(e.target.value as InventoryCategory)}
          >
            {INVENTORY_CATEGORIES.map((item) => (
              <option key={item.value} value={item.value}>
                {item.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      {mode === "create" ? (
        <div className="field">
          <label htmlFor="item_quantity">Quantity</label>
          <input
            id="item_quantity"
            inputMode="decimal"
            value={quantity}
            onChange={(e) => setQuantity(e.target.value)}
            required
          />
        </div>
      ) : null}

      <div className="row-2">
        <div className="field">
          <label htmlFor="item_unit">Unit</label>
          <input
            id="item_unit"
            value={unit}
            onChange={(e) => setUnit(e.target.value)}
            required
          />
        </div>
        <div className="field">
          <label htmlFor="price_per_unit">Price per unit</label>
          <input
            id="price_per_unit"
            inputMode="decimal"
            value={pricePerUnit}
            onChange={(e) => setPricePerUnit(e.target.value)}
            required
          />
        </div>
      </div>

      <div className="field">
        <label htmlFor="item_note">Note</label>
        <textarea
          id="item_note"
          rows={3}
          value={note}
          onChange={(e) => setNote(e.target.value)}
        />
      </div>

      <button className="btn btn-primary" type="submit" disabled={pending}>
        {pending ? "Saving…" : submitLabel}
      </button>
    </form>
  );
}
