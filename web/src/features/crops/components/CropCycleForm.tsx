import { useState, type FormEvent } from "react";
import type { CropCycle, CropCycleCreateInput, CropName } from "../types";

type CropCycleFormProps = {
  initial?: CropCycle;
  cropNames: CropName[];
  submitLabel: string;
  pending?: boolean;
  onSubmit: (input: CropCycleCreateInput) => void;
};

function emptyOrNull(value: string): string | null {
  const trimmed = value.trim();
  return trimmed ? trimmed : null;
}

export function CropCycleForm({
  initial,
  cropNames,
  submitLabel,
  pending,
  onSubmit,
}: CropCycleFormProps) {
  const [cropNameId, setCropNameId] = useState(
    initial?.crop_name_id ?? cropNames[0]?.id ?? "",
  );
  const [plantedAt, setPlantedAt] = useState(initial?.planted_at ?? "");
  const [plotName, setPlotName] = useState(initial?.plot_name ?? "");
  const [area, setArea] = useState(initial?.area ?? "");
  const [location, setLocation] = useState(initial?.location ?? "");
  const [expectedHarvestAt, setExpectedHarvestAt] = useState(
    initial?.expected_harvest_at ?? "",
  );
  const [notes, setNotes] = useState(initial?.notes ?? "");

  function handleSubmit(event: FormEvent) {
    event.preventDefault();
    onSubmit({
      crop_name_id: cropNameId,
      planted_at: plantedAt,
      plot_name: emptyOrNull(plotName),
      area: emptyOrNull(area),
      location: emptyOrNull(location),
      expected_harvest_at: emptyOrNull(expectedHarvestAt),
      notes: emptyOrNull(notes),
    });
  }

  return (
    <form className="form-stack" onSubmit={handleSubmit}>
      <div className="field">
        <label htmlFor="crop_name_id">Crop</label>
        <select
          id="crop_name_id"
          value={cropNameId}
          onChange={(e) => setCropNameId(e.target.value)}
          required
        >
          {cropNames.length === 0 ? (
            <option value="">No active crop names</option>
          ) : null}
          {cropNames.map((name) => (
            <option key={name.id} value={name.id}>
              {name.name}
            </option>
          ))}
        </select>
      </div>

      <div className="row-2">
        <div className="field">
          <label htmlFor="planted_at">Planted at</label>
          <input
            id="planted_at"
            type="date"
            value={plantedAt}
            onChange={(e) => setPlantedAt(e.target.value)}
            required
          />
        </div>
        <div className="field">
          <label htmlFor="expected_harvest_at">Expected harvest</label>
          <input
            id="expected_harvest_at"
            type="date"
            value={expectedHarvestAt}
            onChange={(e) => setExpectedHarvestAt(e.target.value)}
          />
        </div>
      </div>

      <div className="row-2">
        <div className="field">
          <label htmlFor="plot_name">Plot name</label>
          <input
            id="plot_name"
            value={plotName}
            onChange={(e) => setPlotName(e.target.value)}
          />
        </div>
        <div className="field">
          <label htmlFor="area">Area</label>
          <input
            id="area"
            inputMode="decimal"
            value={area}
            onChange={(e) => setArea(e.target.value)}
          />
        </div>
      </div>

      <div className="field">
        <label htmlFor="location">Location</label>
        <input
          id="location"
          value={location}
          onChange={(e) => setLocation(e.target.value)}
        />
      </div>

      <div className="field">
        <label htmlFor="cycle_notes">Notes</label>
        <textarea
          id="cycle_notes"
          rows={3}
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
        />
      </div>

      <button
        className="btn btn-primary"
        type="submit"
        disabled={pending || !cropNameId}
      >
        {pending ? "Saving…" : submitLabel}
      </button>
    </form>
  );
}
