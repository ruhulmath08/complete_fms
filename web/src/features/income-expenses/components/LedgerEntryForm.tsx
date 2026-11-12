import { useState, type FormEvent } from "react";
import {
  ENTRY_CATEGORIES,
  ENTRY_TYPES,
  type EntryCategory,
  type EntryType,
  type LedgerEntry,
  type LedgerEntryCreateInput,
  type LedgerEntryUpdateInput,
} from "../types";

type LedgerEntryFormProps = {
  mode: "create" | "edit";
  initial?: LedgerEntry;
  submitLabel: string;
  pending?: boolean;
  onSubmit: (input: LedgerEntryCreateInput | LedgerEntryUpdateInput) => void;
};

function emptyOrNull(value: string): string | null {
  const trimmed = value.trim();
  return trimmed ? trimmed : null;
}

function todayIsoDate(): string {
  return new Date().toISOString().slice(0, 10);
}

export function LedgerEntryForm({
  mode,
  initial,
  submitLabel,
  pending,
  onSubmit,
}: LedgerEntryFormProps) {
  const [entryType, setEntryType] = useState<EntryType>(
    initial?.entry_type ?? "expense",
  );
  const [occurredAt, setOccurredAt] = useState(
    initial?.occurred_at ?? todayIsoDate(),
  );
  const [category, setCategory] = useState<EntryCategory>(
    initial?.category ?? "other",
  );
  const [amount, setAmount] = useState(initial?.amount ?? "");
  const [unit, setUnit] = useState(initial?.unit ?? "");
  const [note, setNote] = useState(initial?.note ?? "");

  function handleSubmit(event: FormEvent) {
    event.preventDefault();
    const payload = {
      entry_type: entryType,
      occurred_at: occurredAt,
      category,
      amount,
      unit: emptyOrNull(unit),
      note: emptyOrNull(note),
    };
    onSubmit(payload);
  }

  return (
    <form className="form-stack" onSubmit={handleSubmit}>
      <div className="row-2">
        <div className="field">
          <label htmlFor="entry_type">Type</label>
          <select
            id="entry_type"
            value={entryType}
            onChange={(e) => setEntryType(e.target.value as EntryType)}
          >
            {ENTRY_TYPES.map((item) => (
              <option key={item.value} value={item.value}>
                {item.label}
              </option>
            ))}
          </select>
        </div>
        <div className="field">
          <label htmlFor="occurred_at">Date</label>
          <input
            id="occurred_at"
            type="date"
            value={occurredAt}
            onChange={(e) => setOccurredAt(e.target.value)}
            required
          />
        </div>
      </div>

      <div className="row-2">
        <div className="field">
          <label htmlFor="entry_category">Category</label>
          <select
            id="entry_category"
            value={category}
            onChange={(e) => setCategory(e.target.value as EntryCategory)}
          >
            {ENTRY_CATEGORIES.map((item) => (
              <option key={item.value} value={item.value}>
                {item.label}
              </option>
            ))}
          </select>
        </div>
        <div className="field">
          <label htmlFor="entry_amount">Amount</label>
          <input
            id="entry_amount"
            inputMode="decimal"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            required
          />
        </div>
      </div>

      <div className="field">
        <label htmlFor="entry_unit">Unit (optional)</label>
        <input
          id="entry_unit"
          value={unit}
          onChange={(e) => setUnit(e.target.value)}
        />
      </div>

      <div className="field">
        <label htmlFor="entry_note">Note</label>
        <textarea
          id="entry_note"
          rows={3}
          value={note}
          onChange={(e) => setNote(e.target.value)}
        />
      </div>

      {mode === "create" ? (
        <p className="muted">
          Crop-cycle costs belong in Crops, not this general ledger.
        </p>
      ) : null}

      <button className="btn btn-primary" type="submit" disabled={pending}>
        {pending ? "Saving…" : submitLabel}
      </button>
    </form>
  );
}
