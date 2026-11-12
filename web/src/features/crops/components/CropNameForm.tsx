import { useState, type FormEvent } from "react";
import type { CropName, CropNameCreateInput } from "../types";

type CropNameFormProps = {
  initial?: CropName;
  submitLabel: string;
  pending?: boolean;
  onSubmit: (input: CropNameCreateInput) => void;
};

function emptyOrNull(value: string): string | null {
  const trimmed = value.trim();
  return trimmed ? trimmed : null;
}

export function CropNameForm({
  initial,
  submitLabel,
  pending,
  onSubmit,
}: CropNameFormProps) {
  const [name, setName] = useState(initial?.name ?? "");
  const [notes, setNotes] = useState(initial?.notes ?? "");

  function handleSubmit(event: FormEvent) {
    event.preventDefault();
    onSubmit({
      name: name.trim(),
      notes: emptyOrNull(notes),
    });
  }

  return (
    <form className="form-stack" onSubmit={handleSubmit}>
      <div className="field">
        <label htmlFor="crop_name">Crop name</label>
        <input
          id="crop_name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
        />
      </div>
      <div className="field">
        <label htmlFor="crop_name_notes">Notes</label>
        <textarea
          id="crop_name_notes"
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
