import { useState, type FormEvent } from "react";
import { useParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  addCropExpense,
  addHarvest,
  archiveCropCycle,
  deleteCropExpense,
  deleteHarvest,
  getCropCycle,
  getCropCycleSummary,
  getSuggestedUnits,
  listCropExpenses,
  listCropNames,
  listHarvests,
  updateCropCycle,
  updateCropExpense,
  updateHarvest,
} from "../api/cropsApi";
import { CropCycleForm } from "../components/CropCycleForm";
import {
  EXPENSE_CATEGORIES,
  type CropCycleCreateInput,
  type CropExpense,
  type ExpenseCategory,
  type Harvest,
} from "../types";
import { DEFAULT_PAGE_SIZE } from "../../../shared/constants/pagination";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { DeleteIcon, EditIcon } from "../../../shared/ui/ActionIcons";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { PaginationControls } from "../../../shared/ui/PaginationControls";

function categoryLabel(category: string): string {
  return (
    EXPENSE_CATEGORIES.find((item) => item.value === category)?.label ??
    category
  );
}

function SummarySection({ cycleId }: { cycleId: string }) {
  const summaryQuery = useQuery({
    queryKey: ["crop-cycle-summary", cycleId],
    queryFn: () => getCropCycleSummary(cycleId),
  });

  if (summaryQuery.isError) {
    return <ErrorBanner message={getErrorMessage(summaryQuery.error)} />;
  }
  if (summaryQuery.isLoading) {
    return <p className="muted">Loading summary…</p>;
  }
  const summary = summaryQuery.data;
  if (!summary) return null;

  return (
    <dl className="detail-grid">
      <div>
        <dt>Total expenses</dt>
        <dd>{summary.total_expenses}</dd>
      </div>
      <div>
        <dt>Sale income</dt>
        <dd>{summary.total_sale_income}</dd>
      </div>
      <div>
        <dt>Result</dt>
        <dd>{summary.result}</dd>
      </div>
    </dl>
  );
}

function ExpensesSection({
  cycleId,
  canAdd,
}: {
  cycleId: string;
  canAdd: boolean;
}) {
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [offset, setOffset] = useState(0);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [spentAt, setSpentAt] = useState(() =>
    new Date().toISOString().slice(0, 10),
  );
  const [category, setCategory] = useState<ExpenseCategory>("labour");
  const [amount, setAmount] = useState("");
  const [note, setNote] = useState("");

  const listQuery = useQuery({
    queryKey: ["crop-expenses", cycleId, offset],
    queryFn: () =>
      listCropExpenses(cycleId, { limit: DEFAULT_PAGE_SIZE, offset }),
  });

  function resetForm() {
    setEditingId(null);
    setSpentAt(new Date().toISOString().slice(0, 10));
    setCategory("labour");
    setAmount("");
    setNote("");
  }

  function startEdit(row: CropExpense) {
    setEditingId(row.id);
    setSpentAt(row.spent_at);
    setCategory(row.category);
    setAmount(row.amount);
    setNote(row.note ?? "");
    setError(null);
  }

  async function refreshAfterChange() {
    await queryClient.invalidateQueries({
      queryKey: ["crop-expenses", cycleId],
    });
    await queryClient.invalidateQueries({
      queryKey: ["crop-cycle-summary", cycleId],
    });
  }

  const mutation = useMutation({
    mutationFn: () => {
      const payload = {
        spent_at: spentAt,
        category,
        amount,
        note: note.trim() || null,
      };
      if (editingId) return updateCropExpense(cycleId, editingId, payload);
      return addCropExpense(cycleId, payload);
    },
    onSuccess: async () => {
      resetForm();
      setError(null);
      setOffset(0);
      await refreshAfterChange();
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (expenseId: string) => deleteCropExpense(cycleId, expenseId),
    onSuccess: async () => {
      if (editingId) resetForm();
      setError(null);
      await refreshAfterChange();
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onDelete(row: CropExpense) {
    if (!window.confirm("Delete this expense?")) return;
    deleteMutation.mutate(row.id);
  }

  function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    mutation.mutate();
  }

  const items = listQuery.data?.items ?? [];
  const total = listQuery.data?.meta.total ?? 0;

  return (
    <section className="detail-section">
      <h2>Expenses</h2>
      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.isLoading ? (
        <LoadingState message="Loading expenses…" />
      ) : null}
      {!listQuery.isLoading && items.length === 0 ? (
        <p className="muted">No expenses yet.</p>
      ) : null}
      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">No.</th>
                  <th scope="col">Date</th>
                  <th scope="col">Category</th>
                  <th scope="col">Total</th>
                  <th scope="col">Note</th>
                  {canAdd ? <th scope="col">Action</th> : null}
                </tr>
              </thead>
              <tbody>
                {items.map((row, index) => (
                  <tr key={row.id}>
                    <td>{offset + index + 1}</td>
                    <td>{row.spent_at}</td>
                    <td>{categoryLabel(row.category)}</td>
                    <td>{row.amount}</td>
                    <td>{row.note ?? "—"}</td>
                    {canAdd ? (
                      <td>
                        <div className="table-actions">
                          <button
                            type="button"
                            className="btn-icon btn-icon-primary"
                            aria-label="Edit expense"
                            title="Edit"
                            onClick={() => startEdit(row)}
                          >
                            <EditIcon />
                          </button>
                          <button
                            type="button"
                            className="btn-icon btn-icon-danger"
                            aria-label="Delete expense"
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
          <PaginationControls
            total={total}
            limit={DEFAULT_PAGE_SIZE}
            offset={offset}
            onOffsetChange={setOffset}
            label="Crop expenses"
          />
        </>
      ) : null}

      {canAdd ? (
        <>
          <ErrorBanner message={error} />
          <form className="form-stack" onSubmit={onSubmit}>
            <div className="row-2">
              <div className="field">
                <label htmlFor="spent_at">Spent at</label>
                <input
                  id="spent_at"
                  type="date"
                  value={spentAt}
                  onChange={(e) => setSpentAt(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="expense_category">Category</label>
                <select
                  id="expense_category"
                  value={category}
                  onChange={(e) =>
                    setCategory(e.target.value as ExpenseCategory)
                  }
                >
                  {EXPENSE_CATEGORIES.map((item) => (
                    <option key={item.value} value={item.value}>
                      {item.label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            <div className="row-2">
              <div className="field">
                <label htmlFor="expense_amount">Amount</label>
                <input
                  id="expense_amount"
                  inputMode="decimal"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="expense_note">Note</label>
                <input
                  id="expense_note"
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                />
              </div>
            </div>
            <div className="toolbar-actions">
              <button
                className="btn btn-primary"
                type="submit"
                disabled={mutation.isPending}
              >
                {mutation.isPending
                  ? "Saving…"
                  : editingId
                    ? "Update expense"
                    : "Add expense"}
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
          Expenses cannot be added while this cycle is archived.
        </p>
      )}
    </section>
  );
}

function HarvestsSection({
  cycleId,
  canAdd,
}: {
  cycleId: string;
  canAdd: boolean;
}) {
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [offset, setOffset] = useState(0);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [harvestedAt, setHarvestedAt] = useState(() =>
    new Date().toISOString().slice(0, 10),
  );
  const [quantity, setQuantity] = useState("");
  const [unit, setUnit] = useState("kg");
  const [saleAmount, setSaleAmount] = useState("");
  const [note, setNote] = useState("");

  const listQuery = useQuery({
    queryKey: ["harvests", cycleId, offset],
    queryFn: () => listHarvests(cycleId, { limit: DEFAULT_PAGE_SIZE, offset }),
  });
  const unitsQuery = useQuery({
    queryKey: ["suggested-units"],
    queryFn: getSuggestedUnits,
  });

  function resetForm() {
    setEditingId(null);
    setHarvestedAt(new Date().toISOString().slice(0, 10));
    setQuantity("");
    setUnit("kg");
    setSaleAmount("");
    setNote("");
  }

  function startEdit(row: Harvest) {
    setEditingId(row.id);
    setHarvestedAt(row.harvested_at);
    setQuantity(row.quantity);
    setUnit(row.unit);
    setSaleAmount(row.sale_amount ?? "");
    setNote(row.note ?? "");
    setError(null);
  }

  async function refreshAfterChange() {
    await queryClient.invalidateQueries({ queryKey: ["harvests", cycleId] });
    await queryClient.invalidateQueries({
      queryKey: ["crop-cycle-summary", cycleId],
    });
  }

  const mutation = useMutation({
    mutationFn: () => {
      const payload = {
        harvested_at: harvestedAt,
        quantity,
        unit,
        sale_amount: saleAmount.trim() || null,
        note: note.trim() || null,
      };
      if (editingId) return updateHarvest(cycleId, editingId, payload);
      return addHarvest(cycleId, payload);
    },
    onSuccess: async () => {
      resetForm();
      setError(null);
      setOffset(0);
      await refreshAfterChange();
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (harvestId: string) => deleteHarvest(cycleId, harvestId),
    onSuccess: async () => {
      if (editingId) resetForm();
      setError(null);
      await refreshAfterChange();
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onDelete(row: Harvest) {
    if (!window.confirm("Delete this harvest?")) return;
    deleteMutation.mutate(row.id);
  }

  function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    mutation.mutate();
  }

  const items = listQuery.data?.items ?? [];
  const total = listQuery.data?.meta.total ?? 0;

  return (
    <section className="detail-section">
      <h2>Harvests</h2>
      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.isLoading ? (
        <LoadingState message="Loading harvests…" />
      ) : null}
      {!listQuery.isLoading && items.length === 0 ? (
        <p className="muted">No harvests yet.</p>
      ) : null}
      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">No.</th>
                  <th scope="col">Date</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Unit</th>
                  <th scope="col">Sale total</th>
                  <th scope="col">Note</th>
                  {canAdd ? <th scope="col">Action</th> : null}
                </tr>
              </thead>
              <tbody>
                {items.map((row, index) => (
                  <tr key={row.id}>
                    <td>{offset + index + 1}</td>
                    <td>{row.harvested_at}</td>
                    <td>{row.quantity}</td>
                    <td>{row.unit}</td>
                    <td>{row.sale_amount ?? "—"}</td>
                    <td>{row.note ?? "—"}</td>
                    {canAdd ? (
                      <td>
                        <div className="table-actions">
                          <button
                            type="button"
                            className="btn-icon btn-icon-primary"
                            aria-label="Edit harvest"
                            title="Edit"
                            onClick={() => startEdit(row)}
                          >
                            <EditIcon />
                          </button>
                          <button
                            type="button"
                            className="btn-icon btn-icon-danger"
                            aria-label="Delete harvest"
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
          <PaginationControls
            total={total}
            limit={DEFAULT_PAGE_SIZE}
            offset={offset}
            onOffsetChange={setOffset}
            label="Harvests"
          />
        </>
      ) : null}

      {canAdd ? (
        <>
          <ErrorBanner message={error} />
          <form className="form-stack" onSubmit={onSubmit}>
            <div className="row-2">
              <div className="field">
                <label htmlFor="harvested_at">Harvested at</label>
                <input
                  id="harvested_at"
                  type="date"
                  value={harvestedAt}
                  onChange={(e) => setHarvestedAt(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="harvest_quantity">Quantity</label>
                <input
                  id="harvest_quantity"
                  inputMode="decimal"
                  value={quantity}
                  onChange={(e) => setQuantity(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="row-2">
              <div className="field">
                <label htmlFor="harvest_unit">Unit</label>
                <input
                  id="harvest_unit"
                  list="harvest-unit-suggestions"
                  value={unit}
                  onChange={(e) => setUnit(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="sale_amount">Sale amount (optional)</label>
                <input
                  id="sale_amount"
                  inputMode="decimal"
                  value={saleAmount}
                  onChange={(e) => setSaleAmount(e.target.value)}
                />
              </div>
            </div>
            <div className="field">
              <label htmlFor="harvest_note">Note</label>
              <input
                id="harvest_note"
                value={note}
                onChange={(e) => setNote(e.target.value)}
              />
            </div>
            <datalist id="harvest-unit-suggestions">
              {(unitsQuery.data ?? []).map((u) => (
                <option key={u} value={u} />
              ))}
            </datalist>
            <div className="toolbar-actions">
              <button
                className="btn btn-primary"
                type="submit"
                disabled={mutation.isPending}
              >
                {mutation.isPending
                  ? "Saving…"
                  : editingId
                    ? "Update harvest"
                    : "Add harvest"}
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
          Harvests cannot be added while this cycle is archived.
        </p>
      )}
    </section>
  );
}

export function CropCycleDetailPage() {
  const { cycleId = "" } = useParams();
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState(false);

  const cycleQuery = useQuery({
    queryKey: ["crop-cycle", cycleId],
    queryFn: () => getCropCycle(cycleId),
    enabled: Boolean(cycleId),
  });

  const namesQuery = useQuery({
    queryKey: ["crop-names", { includeArchived: true }],
    queryFn: () => listCropNames({ include_archived: true, limit: 100 }),
  });

  const updateMutation = useMutation({
    mutationFn: (input: CropCycleCreateInput) =>
      updateCropCycle(cycleId, input),
    onSuccess: async () => {
      setEditing(false);
      setError(null);
      await queryClient.invalidateQueries({
        queryKey: ["crop-cycle", cycleId],
      });
      await queryClient.invalidateQueries({ queryKey: ["crop-cycles"] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  const archiveMutation = useMutation({
    mutationFn: () => archiveCropCycle(cycleId),
    onSuccess: async () => {
      setEditing(false);
      setError(null);
      await queryClient.invalidateQueries({
        queryKey: ["crop-cycle", cycleId],
      });
      await queryClient.invalidateQueries({ queryKey: ["crop-cycles"] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  if (cycleQuery.isLoading) return <p className="muted">Loading crop cycle…</p>;
  if (cycleQuery.isError) {
    return <ErrorBanner message={getErrorMessage(cycleQuery.error)} />;
  }
  const cycle = cycleQuery.data;
  if (!cycle) return null;

  const cropName =
    namesQuery.data?.items.find((name) => name.id === cycle.crop_name_id)
      ?.name ?? "Crop";
  const canWrite = !cycle.is_archived;
  const activeNames = (namesQuery.data?.items ?? []).filter(
    (name) => !name.is_archived,
  );
  const editNames =
    activeNames.length > 0
      ? activeNames
      : (namesQuery.data?.items ?? []).filter(
          (name) => name.id === cycle.crop_name_id,
        );

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <div className="page-toolbar">
        <div>
          <h1>
            {cropName}
            {cycle.plot_name ? ` · ${cycle.plot_name}` : ""}
          </h1>
          <p className="lede">
            Planted {cycle.planted_at}
            {cycle.is_archived ? " · Archived" : ""}
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
                    "Archive this crop cycle? It will leave the active list.",
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
        <CropCycleForm
          key={cycle.updated_at}
          initial={cycle}
          cropNames={editNames}
          submitLabel="Save changes"
          pending={updateMutation.isPending}
          onSubmit={(input) => updateMutation.mutate(input)}
        />
      ) : (
        <dl className="detail-grid">
          <div>
            <dt>Crop</dt>
            <dd>{cropName}</dd>
          </div>
          <div>
            <dt>Planted at</dt>
            <dd>{cycle.planted_at}</dd>
          </div>
          <div>
            <dt>Expected harvest</dt>
            <dd>{cycle.expected_harvest_at ?? "—"}</dd>
          </div>
          <div>
            <dt>Plot</dt>
            <dd>{cycle.plot_name ?? "—"}</dd>
          </div>
          <div>
            <dt>Area</dt>
            <dd>{cycle.area ?? "—"}</dd>
          </div>
          <div>
            <dt>Location</dt>
            <dd>{cycle.location ?? "—"}</dd>
          </div>
          <div className="detail-span">
            <dt>Notes</dt>
            <dd>{cycle.notes ?? "—"}</dd>
          </div>
        </dl>
      )}

      <section className="detail-section">
        <h2>Summary</h2>
        <SummarySection cycleId={cycle.id} />
      </section>

      <ExpensesSection cycleId={cycle.id} canAdd={canWrite} />
      <HarvestsSection cycleId={cycle.id} canAdd={canWrite} />
    </div>
  );
}
