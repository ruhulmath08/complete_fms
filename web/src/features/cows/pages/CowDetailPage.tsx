import { useState, type FormEvent } from "react";
import { useParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  addFeeding,
  addMilkProduction,
  archiveCow,
  deleteFeeding,
  deleteMilkProduction,
  getCow,
  getSuggestedUnits,
  listFeedings,
  listMilkProductions,
  updateCow,
  updateFeeding,
  updateMilkProduction,
  uploadCowImage,
} from "../api/cowsApi";
import type { CowFeeding, MilkProduction } from "../types";
import { CowForm } from "../components/CowForm";
import { PaginationControls } from "../components/PaginationControls";
import { useCowImageUrl } from "../hooks/useCowImageUrl";
import type { CowCreateInput } from "../types";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";

const PAGE_SIZE = 10;

function toDateTimeLocalValue(iso: string): string {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "";
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function fromDateTimeLocalValue(value: string): string {
  return new Date(value).toISOString();
}

function rowTotal(
  quantity: string,
  unitPrice: string,
  apiTotal?: string,
): string {
  if (apiTotal != null && apiTotal !== "") return apiTotal;
  const qty = Number(quantity);
  const price = Number(unitPrice);
  if (Number.isNaN(qty) || Number.isNaN(price)) return "—";
  return (qty * price).toFixed(2);
}

function EditIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" aria-hidden="true">
      <path
        fill="currentColor"
        d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zm17.71-10.04a1.003 1.003 0 0 0 0-1.42l-2.5-2.5a1.003 1.003 0 0 0-1.42 0l-1.83 1.83 3.75 3.75 1.999-1.66z"
      />
    </svg>
  );
}

function DeleteIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" aria-hidden="true">
      <path
        fill="currentColor"
        d="M6 19a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"
      />
    </svg>
  );
}

function MilkSection({ cowId, canAdd }: { cowId: string; canAdd: boolean }) {
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [offset, setOffset] = useState(0);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [producedAt, setProducedAt] = useState(() =>
    toDateTimeLocalValue(new Date().toISOString()),
  );
  const [quantity, setQuantity] = useState("");
  const [unit, setUnit] = useState("L");
  const [pricePerUnit, setPricePerUnit] = useState("0");
  const [note, setNote] = useState("");

  const listQuery = useQuery({
    queryKey: ["milk", cowId, offset],
    queryFn: () => listMilkProductions(cowId, { limit: PAGE_SIZE, offset }),
  });
  const unitsQuery = useQuery({
    queryKey: ["suggested-units"],
    queryFn: getSuggestedUnits,
  });

  function resetForm() {
    setEditingId(null);
    setProducedAt(toDateTimeLocalValue(new Date().toISOString()));
    setQuantity("");
    setUnit("L");
    setPricePerUnit("0");
    setNote("");
  }

  function startEdit(row: MilkProduction) {
    setEditingId(row.id);
    setProducedAt(toDateTimeLocalValue(row.produced_at));
    setQuantity(row.quantity);
    setUnit(row.unit);
    setPricePerUnit(row.price_per_unit);
    setNote(row.note ?? "");
    setError(null);
  }

  const saveMutation = useMutation({
    mutationFn: () => {
      const payload = {
        produced_at: fromDateTimeLocalValue(producedAt),
        quantity,
        unit,
        price_per_unit: pricePerUnit,
        note: note.trim() || null,
      };
      if (editingId) return updateMilkProduction(cowId, editingId, payload);
      return addMilkProduction(cowId, payload);
    },
    onSuccess: async () => {
      resetForm();
      setError(null);
      setOffset(0);
      await queryClient.invalidateQueries({ queryKey: ["milk", cowId] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (milkId: string) => deleteMilkProduction(cowId, milkId),
    onSuccess: async () => {
      if (editingId) resetForm();
      setError(null);
      await queryClient.invalidateQueries({ queryKey: ["milk", cowId] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    saveMutation.mutate();
  }

  function onDelete(row: MilkProduction) {
    if (!window.confirm("Delete this milk entry?")) return;
    deleteMutation.mutate(row.id);
  }

  const items = listQuery.data?.items ?? [];
  const meta = listQuery.data?.meta;

  return (
    <section className="detail-section">
      <h2>Milk production</h2>
      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.isLoading ? (
        <p className="muted">Loading milk entries…</p>
      ) : null}
      {!listQuery.isLoading && items.length === 0 ? (
        <p className="muted">No milk entries yet.</p>
      ) : null}
      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">No</th>
                  <th scope="col">Date + time</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Unit price</th>
                  <th scope="col">Total</th>
                  <th scope="col">Note</th>
                  {canAdd ? <th scope="col">Action</th> : null}
                </tr>
              </thead>
              <tbody>
                {items.map((row, index) => (
                  <tr key={row.id}>
                    <td>{offset + index + 1}</td>
                    <td>{new Date(row.produced_at).toLocaleString()}</td>
                    <td>
                      {row.quantity} {row.unit}
                    </td>
                    <td>{row.price_per_unit}</td>
                    <td>
                      {rowTotal(row.quantity, row.price_per_unit, row.total)}
                    </td>
                    <td>{row.note ?? "—"}</td>
                    {canAdd ? (
                      <td>
                        <div className="table-actions">
                          <button
                            type="button"
                            className="btn-icon"
                            aria-label="Edit milk entry"
                            title="Edit"
                            onClick={() => startEdit(row)}
                          >
                            <EditIcon />
                          </button>
                          <button
                            type="button"
                            className="btn-icon btn-icon-danger"
                            aria-label="Delete milk entry"
                            title="Delete"
                            disabled={deleteMutation.isPending}
                            onClick={() => onDelete(row)}
                          >
                            <DeleteIcon />
                          </button>
                        </div>
                      </td>
                    ) : null}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {meta ? (
            <PaginationControls
              label="Milk"
              total={meta.total}
              limit={meta.limit}
              offset={meta.offset}
              onOffsetChange={setOffset}
            />
          ) : null}
        </>
      ) : null}

      {canAdd ? (
        <>
          <ErrorBanner message={error} />
          <form className="form-stack" onSubmit={onSubmit}>
            <div className="row-2">
              <div className="field">
                <label htmlFor="produced_at">Produced at</label>
                <input
                  id="produced_at"
                  type="datetime-local"
                  value={producedAt}
                  onChange={(e) => setProducedAt(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="milk_quantity">Quantity</label>
                <input
                  id="milk_quantity"
                  value={quantity}
                  onChange={(e) => setQuantity(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="row-2">
              <div className="field">
                <label htmlFor="milk_unit">Unit</label>
                <input
                  id="milk_unit"
                  list="unit-suggestions"
                  value={unit}
                  onChange={(e) => setUnit(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="price_per_unit">Price per unit</label>
                <input
                  id="price_per_unit"
                  value={pricePerUnit}
                  onChange={(e) => setPricePerUnit(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="field">
              <label htmlFor="milk_note">Note</label>
              <input
                id="milk_note"
                value={note}
                onChange={(e) => setNote(e.target.value)}
              />
            </div>
            <datalist id="unit-suggestions">
              {(unitsQuery.data ?? []).map((u) => (
                <option key={u} value={u} />
              ))}
            </datalist>
            <div className="toolbar-actions">
              <button
                className="btn btn-primary"
                type="submit"
                disabled={saveMutation.isPending}
              >
                {saveMutation.isPending
                  ? "Saving…"
                  : editingId
                    ? "Update milk entry"
                    : "Add milk entry"}
              </button>
              {editingId ? (
                <button
                  type="button"
                  className="btn btn-ghost"
                  onClick={resetForm}
                >
                  Cancel edit
                </button>
              ) : null}
            </div>
          </form>
        </>
      ) : (
        <p className="muted">Milk recording is unavailable for this cow.</p>
      )}
    </section>
  );
}

function FeedingSection({ cowId, canAdd }: { cowId: string; canAdd: boolean }) {
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [offset, setOffset] = useState(0);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [fedAt, setFedAt] = useState(() =>
    toDateTimeLocalValue(new Date().toISOString()),
  );
  const [feedName, setFeedName] = useState("");
  const [quantity, setQuantity] = useState("");
  const [unit, setUnit] = useState("kg");
  const [unitCost, setUnitCost] = useState("0");
  const [note, setNote] = useState("");

  const listQuery = useQuery({
    queryKey: ["feedings", cowId, offset],
    queryFn: () => listFeedings(cowId, { limit: PAGE_SIZE, offset }),
  });
  const unitsQuery = useQuery({
    queryKey: ["suggested-units"],
    queryFn: getSuggestedUnits,
  });

  function resetForm() {
    setEditingId(null);
    setFedAt(toDateTimeLocalValue(new Date().toISOString()));
    setFeedName("");
    setQuantity("");
    setUnit("kg");
    setUnitCost("0");
    setNote("");
  }

  function startEdit(row: CowFeeding) {
    setEditingId(row.id);
    setFedAt(toDateTimeLocalValue(row.fed_at));
    setFeedName(row.feed_name);
    setQuantity(row.quantity);
    setUnit(row.unit);
    setUnitCost(row.unit_cost);
    setNote(row.note ?? "");
    setError(null);
  }

  const saveMutation = useMutation({
    mutationFn: () => {
      const payload = {
        fed_at: fromDateTimeLocalValue(fedAt),
        feed_name: feedName,
        quantity,
        unit,
        unit_cost: unitCost,
        note: note.trim() || null,
      };
      if (editingId) return updateFeeding(cowId, editingId, payload);
      return addFeeding(cowId, payload);
    },
    onSuccess: async () => {
      resetForm();
      setError(null);
      setOffset(0);
      await queryClient.invalidateQueries({ queryKey: ["feedings", cowId] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (feedingId: string) => deleteFeeding(cowId, feedingId),
    onSuccess: async () => {
      if (editingId) resetForm();
      setError(null);
      await queryClient.invalidateQueries({ queryKey: ["feedings", cowId] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    saveMutation.mutate();
  }

  function onDelete(row: CowFeeding) {
    if (!window.confirm("Delete this feeding entry?")) return;
    deleteMutation.mutate(row.id);
  }

  const items = listQuery.data?.items ?? [];
  const meta = listQuery.data?.meta;

  return (
    <section className="detail-section">
      <h2>Feeding</h2>
      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.isLoading ? (
        <p className="muted">Loading feeding entries…</p>
      ) : null}
      {!listQuery.isLoading && items.length === 0 ? (
        <p className="muted">No feeding entries yet.</p>
      ) : null}
      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">No</th>
                  <th scope="col">Date + time</th>
                  <th scope="col">Feed name</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Unit</th>
                  <th scope="col">Unit cost</th>
                  <th scope="col">Total</th>
                  <th scope="col">Note</th>
                  {canAdd ? <th scope="col">Action</th> : null}
                </tr>
              </thead>
              <tbody>
                {items.map((row, index) => (
                  <tr key={row.id}>
                    <td>{offset + index + 1}</td>
                    <td>{new Date(row.fed_at).toLocaleString()}</td>
                    <td>{row.feed_name}</td>
                    <td>{row.quantity}</td>
                    <td>{row.unit}</td>
                    <td>{row.unit_cost}</td>
                    <td>{rowTotal(row.quantity, row.unit_cost, row.total)}</td>
                    <td>{row.note ?? "—"}</td>
                    {canAdd ? (
                      <td>
                        <div className="table-actions">
                          <button
                            type="button"
                            className="btn-icon"
                            aria-label="Edit feeding entry"
                            title="Edit"
                            onClick={() => startEdit(row)}
                          >
                            <EditIcon />
                          </button>
                          <button
                            type="button"
                            className="btn-icon btn-icon-danger"
                            aria-label="Delete feeding entry"
                            title="Delete"
                            disabled={deleteMutation.isPending}
                            onClick={() => onDelete(row)}
                          >
                            <DeleteIcon />
                          </button>
                        </div>
                      </td>
                    ) : null}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {meta ? (
            <PaginationControls
              label="Feeding"
              total={meta.total}
              limit={meta.limit}
              offset={meta.offset}
              onOffsetChange={setOffset}
            />
          ) : null}
        </>
      ) : null}

      {canAdd ? (
        <>
          <ErrorBanner message={error} />
          <form className="form-stack" onSubmit={onSubmit}>
            <div className="row-2">
              <div className="field">
                <label htmlFor="fed_at">Fed at</label>
                <input
                  id="fed_at"
                  type="datetime-local"
                  value={fedAt}
                  onChange={(e) => setFedAt(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="feed_name">Feed name</label>
                <input
                  id="feed_name"
                  value={feedName}
                  onChange={(e) => setFeedName(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="row-2">
              <div className="field">
                <label htmlFor="feed_quantity">Quantity</label>
                <input
                  id="feed_quantity"
                  value={quantity}
                  onChange={(e) => setQuantity(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="feed_unit">Unit</label>
                <input
                  id="feed_unit"
                  list="feed-unit-suggestions"
                  value={unit}
                  onChange={(e) => setUnit(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="row-2">
              <div className="field">
                <label htmlFor="feed_unit_cost">Unit cost</label>
                <input
                  id="feed_unit_cost"
                  value={unitCost}
                  onChange={(e) => setUnitCost(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="feed_note">Note</label>
                <input
                  id="feed_note"
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                />
              </div>
            </div>
            <datalist id="feed-unit-suggestions">
              {(unitsQuery.data ?? []).map((u) => (
                <option key={u} value={u} />
              ))}
            </datalist>
            <div className="toolbar-actions">
              <button
                className="btn btn-primary"
                type="submit"
                disabled={saveMutation.isPending}
              >
                {saveMutation.isPending
                  ? "Saving…"
                  : editingId
                    ? "Update feeding"
                    : "Add feeding"}
              </button>
              {editingId ? (
                <button
                  type="button"
                  className="btn btn-ghost"
                  onClick={resetForm}
                >
                  Cancel edit
                </button>
              ) : null}
            </div>
          </form>
        </>
      ) : (
        <p className="muted">
          Feeding cannot be added while this cow is archived.
        </p>
      )}
    </section>
  );
}

export function CowDetailPage() {
  const { cowId = "" } = useParams();
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState(false);

  const cowQuery = useQuery({
    queryKey: ["cow", cowId],
    queryFn: () => getCow(cowId),
    enabled: Boolean(cowId),
  });

  const cow = cowQuery.data;
  const imageUrl = useCowImageUrl(cow?.id, cow?.image_url);

  const updateMutation = useMutation({
    mutationFn: async ({
      input,
      imageFile,
    }: {
      input: CowCreateInput;
      imageFile: File | null;
    }) => {
      const updated = await updateCow(cowId, input);
      if (imageFile) {
        return uploadCowImage(cowId, imageFile);
      }
      return updated;
    },
    onSuccess: async () => {
      setEditing(false);
      setError(null);
      await queryClient.invalidateQueries({ queryKey: ["cow", cowId] });
      await queryClient.invalidateQueries({ queryKey: ["cows"] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  const archiveMutation = useMutation({
    mutationFn: () => archiveCow(cowId),
    onSuccess: async () => {
      setEditing(false);
      setError(null);
      await queryClient.invalidateQueries({ queryKey: ["cow", cowId] });
      await queryClient.invalidateQueries({ queryKey: ["cows"] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  if (cowQuery.isLoading) return <p className="muted">Loading cow…</p>;
  if (cowQuery.isError) {
    return <ErrorBanner message={getErrorMessage(cowQuery.error)} />;
  }
  if (!cow) return null;

  const milkEligible = cow.purpose === "milk" || cow.purpose === "both";
  const canWrite = !cow.is_archived;

  const imageAlt = cow.name
    ? `Photo of ${cow.name} (${cow.tag_number})`
    : `Photo of cow ${cow.tag_number}`;

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <div className="page-toolbar">
        <div>
          <h1>
            {cow.tag_number}
            {cow.name ? ` · ${cow.name}` : ""}
          </h1>
          <p className="lede">
            {cow.purpose} · {cow.gender}
            {cow.is_archived ? " · Archived" : ""}
          </p>
        </div>
        {canWrite ? (
          <div className="toolbar-actions">
            <button
              type="button"
              className={editing ? "btn btn-ghost" : "btn btn-primary"}
              onClick={() => setEditing((v) => !v)}
            >
              {editing ? "Cancel edit" : "Edit"}
            </button>
            <button
              type="button"
              className="btn btn-danger-ghost"
              disabled={archiveMutation.isPending}
              onClick={() => {
                if (
                  window.confirm(
                    "Archive this cow? It will leave the active list.",
                  )
                ) {
                  archiveMutation.mutate();
                }
              }}
            >
              Archive
            </button>
          </div>
        ) : null}
      </div>

      <ErrorBanner message={error} />

      {editing && canWrite ? (
        <CowForm
          key={cow.updated_at}
          initial={cow}
          submitLabel="Save changes"
          pending={updateMutation.isPending}
          onSubmit={(input, imageFile) =>
            updateMutation.mutate({ input, imageFile })
          }
        />
      ) : (
        <div className="detail-chrome">
          <div className="detail-chrome__media">
            {imageUrl ? (
              <img
                src={imageUrl}
                alt={imageAlt}
                className="detail-chrome__image"
              />
            ) : (
              <div
                className="detail-chrome__placeholder"
                role="img"
                aria-label="No cow photo"
              >
                No photo
              </div>
            )}
          </div>
          <dl className="detail-grid detail-chrome__info">
            <div>
              <dt>Breed</dt>
              <dd>{cow.breed ?? "—"}</dd>
            </div>
            <div>
              <dt>Color</dt>
              <dd>{cow.color ?? "—"}</dd>
            </div>
            <div>
              <dt>Date of birth</dt>
              <dd>{cow.date_of_birth ?? "—"}</dd>
            </div>
            <div>
              <dt>Age</dt>
              <dd>{cow.age ?? "—"}</dd>
            </div>
            <div>
              <dt>Weight (kg)</dt>
              <dd>{cow.weight ?? "—"}</dd>
            </div>
            <div>
              <dt>Acquired by</dt>
              <dd>{cow.acquired_by}</dd>
            </div>
            {cow.acquired_by === "purchased" ? (
              <>
                <div>
                  <dt>Purchase date</dt>
                  <dd>{cow.purchase_date ?? "—"}</dd>
                </div>
                <div>
                  <dt>Purchase price</dt>
                  <dd>{cow.purchase_price ?? "—"}</dd>
                </div>
              </>
            ) : null}
            <div className="detail-span">
              <dt>Notes</dt>
              <dd>{cow.notes ?? "—"}</dd>
            </div>
          </dl>
        </div>
      )}

      {milkEligible ? (
        <MilkSection cowId={cow.id} canAdd={canWrite} />
      ) : (
        <section className="detail-section">
          <h2>Milk production</h2>
          <p className="muted">Meat-purpose cows do not record milk.</p>
        </section>
      )}

      <FeedingSection cowId={cow.id} canAdd={canWrite} />
    </div>
  );
}
