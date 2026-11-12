import { useState, type FormEvent } from "react";
import { useParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  addEggProduction,
  addPoultryFeeding,
  archivePoultryGroup,
  getPoultryGroup,
  getSuggestedUnits,
  listEggProductions,
  listPoultryFeedings,
  updatePoultryGroup,
} from "../api/poultryApi";
import { PoultryGroupForm } from "../components/PoultryGroupForm";
import type { PoultryGroupCreateInput } from "../types";
import { DEFAULT_PAGE_SIZE } from "../../../shared/constants/pagination";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { PaginationControls } from "../../../shared/ui/PaginationControls";

function rowTotal(quantity: string, unitPrice: string): string {
  const qty = Number(quantity);
  const price = Number(unitPrice);
  if (!Number.isFinite(qty) || !Number.isFinite(price)) return "—";
  return (qty * price).toFixed(2);
}

function toDateTimeLocalValue(iso: string): string {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "";
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function fromDateTimeLocalValue(value: string): string {
  return new Date(value).toISOString();
}

function EggSection({ groupId, canAdd }: { groupId: string; canAdd: boolean }) {
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [offset, setOffset] = useState(0);
  const [producedAt, setProducedAt] = useState(() =>
    toDateTimeLocalValue(new Date().toISOString()),
  );
  const [quantity, setQuantity] = useState("");
  const [unit, setUnit] = useState("pcs");
  const [pricePerUnit, setPricePerUnit] = useState("0");
  const [note, setNote] = useState("");

  const listQuery = useQuery({
    queryKey: ["eggs", groupId, offset],
    queryFn: () =>
      listEggProductions(groupId, { limit: DEFAULT_PAGE_SIZE, offset }),
  });
  const unitsQuery = useQuery({
    queryKey: ["suggested-units"],
    queryFn: getSuggestedUnits,
  });

  const mutation = useMutation({
    mutationFn: () =>
      addEggProduction(groupId, {
        produced_at: fromDateTimeLocalValue(producedAt),
        quantity,
        unit,
        price_per_unit: pricePerUnit,
        note: note.trim() || null,
      }),
    onSuccess: async () => {
      setQuantity("");
      setNote("");
      setError(null);
      setOffset(0);
      await queryClient.invalidateQueries({ queryKey: ["eggs", groupId] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    mutation.mutate();
  }

  const items = listQuery.data?.items ?? [];
  const total = listQuery.data?.meta.total ?? 0;

  return (
    <section className="detail-section">
      <h2>Egg production</h2>
      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.isLoading ? (
        <LoadingState message="Loading egg entries…" />
      ) : null}
      {!listQuery.isLoading && items.length === 0 ? (
        <p className="muted">No egg entries yet.</p>
      ) : null}
      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">#</th>
                  <th scope="col">Produced at</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Unit</th>
                  <th scope="col">Unit price</th>
                  <th scope="col">Total</th>
                  <th scope="col">Note</th>
                </tr>
              </thead>
              <tbody>
                {items.map((row, index) => (
                  <tr key={row.id}>
                    <td>{offset + index + 1}</td>
                    <td>{new Date(row.produced_at).toLocaleString()}</td>
                    <td>{row.quantity}</td>
                    <td>{row.unit}</td>
                    <td>{row.price_per_unit}</td>
                    <td>{rowTotal(row.quantity, row.price_per_unit)}</td>
                    <td>{row.note ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationControls
            total={total}
            limit={DEFAULT_PAGE_SIZE}
            offset={offset}
            onOffsetChange={setOffset}
            label="Egg production"
          />
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
                <label htmlFor="egg_quantity">Quantity</label>
                <input
                  id="egg_quantity"
                  value={quantity}
                  onChange={(e) => setQuantity(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="row-2">
              <div className="field">
                <label htmlFor="egg_unit">Unit</label>
                <input
                  id="egg_unit"
                  list="egg-unit-suggestions"
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
              <label htmlFor="egg_note">Note</label>
              <input
                id="egg_note"
                value={note}
                onChange={(e) => setNote(e.target.value)}
              />
            </div>
            <datalist id="egg-unit-suggestions">
              {(unitsQuery.data ?? []).map((u) => (
                <option key={u} value={u} />
              ))}
            </datalist>
            <button
              className="btn btn-primary"
              type="submit"
              disabled={mutation.isPending}
            >
              {mutation.isPending ? "Saving…" : "Add egg entry"}
            </button>
          </form>
        </>
      ) : (
        <p className="muted">Egg recording is unavailable for this group.</p>
      )}
    </section>
  );
}

function FeedingSection({
  groupId,
  canAdd,
}: {
  groupId: string;
  canAdd: boolean;
}) {
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [offset, setOffset] = useState(0);
  const [fedAt, setFedAt] = useState(() =>
    toDateTimeLocalValue(new Date().toISOString()),
  );
  const [feedName, setFeedName] = useState("");
  const [quantity, setQuantity] = useState("");
  const [unit, setUnit] = useState("kg");
  const [note, setNote] = useState("");

  const listQuery = useQuery({
    queryKey: ["poultry-feedings", groupId, offset],
    queryFn: () =>
      listPoultryFeedings(groupId, { limit: DEFAULT_PAGE_SIZE, offset }),
  });
  const unitsQuery = useQuery({
    queryKey: ["suggested-units"],
    queryFn: getSuggestedUnits,
  });

  const mutation = useMutation({
    mutationFn: () =>
      addPoultryFeeding(groupId, {
        fed_at: fromDateTimeLocalValue(fedAt),
        feed_name: feedName,
        quantity,
        unit,
        note: note.trim() || null,
      }),
    onSuccess: async () => {
      setFeedName("");
      setQuantity("");
      setNote("");
      setError(null);
      setOffset(0);
      await queryClient.invalidateQueries({
        queryKey: ["poultry-feedings", groupId],
      });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    mutation.mutate();
  }

  const items = listQuery.data?.items ?? [];
  const total = listQuery.data?.meta.total ?? 0;

  return (
    <section className="detail-section">
      <h2>Feeding</h2>
      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.isLoading ? (
        <LoadingState message="Loading feeding entries…" />
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
                  <th scope="col">#</th>
                  <th scope="col">Fed at</th>
                  <th scope="col">Feed</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Unit</th>
                  <th scope="col">Note</th>
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
                    <td>{row.note ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationControls
            total={total}
            limit={DEFAULT_PAGE_SIZE}
            offset={offset}
            onOffsetChange={setOffset}
            label="Poultry feeding"
          />
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
                  list="poultry-feed-unit-suggestions"
                  value={unit}
                  onChange={(e) => setUnit(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="field">
              <label htmlFor="feed_note">Note</label>
              <input
                id="feed_note"
                value={note}
                onChange={(e) => setNote(e.target.value)}
              />
            </div>
            <datalist id="poultry-feed-unit-suggestions">
              {(unitsQuery.data ?? []).map((u) => (
                <option key={u} value={u} />
              ))}
            </datalist>
            <button
              className="btn btn-primary"
              type="submit"
              disabled={mutation.isPending}
            >
              {mutation.isPending ? "Saving…" : "Add feeding"}
            </button>
          </form>
        </>
      ) : (
        <p className="muted">
          Feeding cannot be added while this group is archived.
        </p>
      )}
    </section>
  );
}

export function PoultryDetailPage() {
  const { groupId = "" } = useParams();
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState(false);

  const groupQuery = useQuery({
    queryKey: ["poultry-group", groupId],
    queryFn: () => getPoultryGroup(groupId),
    enabled: Boolean(groupId),
  });

  const updateMutation = useMutation({
    mutationFn: (input: PoultryGroupCreateInput) =>
      updatePoultryGroup(groupId, input),
    onSuccess: async () => {
      setEditing(false);
      setError(null);
      await queryClient.invalidateQueries({
        queryKey: ["poultry-group", groupId],
      });
      await queryClient.invalidateQueries({ queryKey: ["poultry-groups"] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  const archiveMutation = useMutation({
    mutationFn: () => archivePoultryGroup(groupId),
    onSuccess: async () => {
      setEditing(false);
      setError(null);
      await queryClient.invalidateQueries({
        queryKey: ["poultry-group", groupId],
      });
      await queryClient.invalidateQueries({ queryKey: ["poultry-groups"] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  if (groupQuery.isLoading)
    return <p className="muted">Loading poultry group…</p>;
  if (groupQuery.isError) {
    return <ErrorBanner message={getErrorMessage(groupQuery.error)} />;
  }
  const group = groupQuery.data;
  if (!group) return null;

  const eggsEligible =
    group.poultry_type === "duck" ||
    group.poultry_type === "layer" ||
    group.poultry_type === "local";
  const canWrite = !group.is_archived;

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <div className="page-toolbar">
        <div>
          <h1>{group.name}</h1>
          <p className="lede">
            {group.poultry_type} · {group.bird_count} birds
            {group.is_archived ? " · Archived" : ""}
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
                    "Archive this poultry group? It will leave the active list.",
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
        <PoultryGroupForm
          key={group.updated_at}
          initial={group}
          submitLabel="Save changes"
          pending={updateMutation.isPending}
          onSubmit={(input) => updateMutation.mutate(input)}
        />
      ) : (
        <dl className="detail-grid">
          <div>
            <dt>Type</dt>
            <dd>{group.poultry_type}</dd>
          </div>
          <div>
            <dt>Bird count</dt>
            <dd>{group.bird_count}</dd>
          </div>
          <div>
            <dt>Date acquired</dt>
            <dd>{group.date_acquired ?? "—"}</dd>
          </div>
          <div>
            <dt>Acquired by</dt>
            <dd>{group.acquired_by}</dd>
          </div>
          {group.acquired_by === "purchased" ? (
            <>
              <div>
                <dt>Purchase date</dt>
                <dd>{group.purchase_date ?? "—"}</dd>
              </div>
              <div>
                <dt>Purchase price</dt>
                <dd>{group.purchase_price ?? "—"}</dd>
              </div>
            </>
          ) : null}
          <div className="detail-span">
            <dt>Notes</dt>
            <dd>{group.notes ?? "—"}</dd>
          </div>
        </dl>
      )}

      {eggsEligible ? (
        <EggSection groupId={group.id} canAdd={canWrite} />
      ) : (
        <section className="detail-section">
          <h2>Egg production</h2>
          <p className="muted">Broiler groups do not record egg production.</p>
        </section>
      )}

      <FeedingSection groupId={group.id} canAdd={canWrite} />
    </div>
  );
}
