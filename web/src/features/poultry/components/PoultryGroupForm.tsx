import { useState, type FormEvent } from "react";
import type {
  AcquisitionSource,
  PoultryGroup,
  PoultryGroupCreateInput,
  PoultryType,
} from "../types";

type PoultryGroupFormProps = {
  initial?: PoultryGroup;
  submitLabel: string;
  pending?: boolean;
  onSubmit: (input: PoultryGroupCreateInput) => void;
};

function emptyOrNull(value: string): string | null {
  const trimmed = value.trim();
  return trimmed ? trimmed : null;
}

export function PoultryGroupForm({
  initial,
  submitLabel,
  pending,
  onSubmit,
}: PoultryGroupFormProps) {
  const [poultryType, setPoultryType] = useState<PoultryType>(
    initial?.poultry_type ?? "layer",
  );
  const [name, setName] = useState(initial?.name ?? "");
  const [birdCount, setBirdCount] = useState(
    initial?.bird_count != null ? String(initial.bird_count) : "0",
  );
  const [dateAcquired, setDateAcquired] = useState(
    initial?.date_acquired ?? "",
  );
  const [acquiredBy, setAcquiredBy] = useState<AcquisitionSource>(
    initial?.acquired_by ?? "born_on_farm",
  );
  const [purchaseDate, setPurchaseDate] = useState(
    initial?.purchase_date ?? "",
  );
  const [purchasePrice, setPurchasePrice] = useState(
    initial?.purchase_price ?? "",
  );
  const [notes, setNotes] = useState(initial?.notes ?? "");

  function handleSubmit(event: FormEvent) {
    event.preventDefault();
    const input: PoultryGroupCreateInput = {
      poultry_type: poultryType,
      name: name.trim(),
      bird_count: Number(birdCount),
      acquired_by: acquiredBy,
      date_acquired: emptyOrNull(dateAcquired),
      notes: emptyOrNull(notes),
      purchase_date:
        acquiredBy === "purchased" ? emptyOrNull(purchaseDate) : null,
      purchase_price:
        acquiredBy === "purchased" ? emptyOrNull(purchasePrice) : null,
    };
    onSubmit(input);
  }

  return (
    <form className="form-stack" onSubmit={handleSubmit}>
      <div className="row-2">
        <div className="field">
          <label htmlFor="name">Group name</label>
          <input
            id="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>
        <div className="field">
          <label htmlFor="poultry_type">Poultry type</label>
          <select
            id="poultry_type"
            value={poultryType}
            onChange={(e) => setPoultryType(e.target.value as PoultryType)}
          >
            <option value="broiler">Broiler</option>
            <option value="duck">Duck</option>
            <option value="layer">Layer</option>
            <option value="local">Local</option>
          </select>
        </div>
      </div>

      <div className="row-2">
        <div className="field">
          <label htmlFor="bird_count">Bird count</label>
          <input
            id="bird_count"
            type="number"
            min={0}
            value={birdCount}
            onChange={(e) => setBirdCount(e.target.value)}
            required
          />
        </div>
        <div className="field">
          <label htmlFor="date_acquired">Date acquired</label>
          <input
            id="date_acquired"
            type="date"
            value={dateAcquired}
            onChange={(e) => setDateAcquired(e.target.value)}
          />
        </div>
      </div>

      <div className="field">
        <label htmlFor="acquired_by">Acquired by</label>
        <select
          id="acquired_by"
          value={acquiredBy}
          onChange={(e) => setAcquiredBy(e.target.value as AcquisitionSource)}
        >
          <option value="born_on_farm">Born on farm</option>
          <option value="purchased">Purchased</option>
        </select>
      </div>

      {acquiredBy === "purchased" ? (
        <div className="row-2">
          <div className="field">
            <label htmlFor="purchase_date">Purchase date</label>
            <input
              id="purchase_date"
              type="date"
              value={purchaseDate}
              onChange={(e) => setPurchaseDate(e.target.value)}
              required
            />
          </div>
          <div className="field">
            <label htmlFor="purchase_price">Purchase price</label>
            <input
              id="purchase_price"
              inputMode="decimal"
              value={purchasePrice}
              onChange={(e) => setPurchasePrice(e.target.value)}
              required
            />
          </div>
        </div>
      ) : null}

      <div className="field">
        <label htmlFor="notes">Notes</label>
        <textarea
          id="notes"
          rows={3}
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
        />
      </div>

      <button className="btn btn-primary" type="submit" disabled={pending}>
        {pending ? "Saving…" : submitLabel}
      </button>
    </form>
  );
}
