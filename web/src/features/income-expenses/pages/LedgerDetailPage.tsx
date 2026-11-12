import { useState } from "react";
import { useParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  archiveLedgerEntry,
  getLedgerEntry,
  updateLedgerEntry,
} from "../api/ledgerApi";
import { LedgerEntryForm } from "../components/LedgerEntryForm";
import {
  ENTRY_CATEGORIES,
  ENTRY_TYPES,
  type LedgerEntryUpdateInput,
} from "../types";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";

function typeLabel(value: string): string {
  return ENTRY_TYPES.find((item) => item.value === value)?.label ?? value;
}

function categoryLabel(value: string): string {
  return ENTRY_CATEGORIES.find((item) => item.value === value)?.label ?? value;
}

export function LedgerDetailPage() {
  const { entryId = "" } = useParams();
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState(false);

  const entryQuery = useQuery({
    queryKey: ["ledger-entry", entryId],
    queryFn: () => getLedgerEntry(entryId),
    enabled: Boolean(entryId),
  });

  const updateMutation = useMutation({
    mutationFn: (input: LedgerEntryUpdateInput) =>
      updateLedgerEntry(entryId, input),
    onSuccess: async () => {
      setEditing(false);
      setError(null);
      await queryClient.invalidateQueries({
        queryKey: ["ledger-entry", entryId],
      });
      await queryClient.invalidateQueries({ queryKey: ["ledger-entries"] });
      await queryClient.invalidateQueries({ queryKey: ["ledger-totals"] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  const archiveMutation = useMutation({
    mutationFn: () => archiveLedgerEntry(entryId),
    onSuccess: async () => {
      setEditing(false);
      setError(null);
      await queryClient.invalidateQueries({
        queryKey: ["ledger-entry", entryId],
      });
      await queryClient.invalidateQueries({ queryKey: ["ledger-entries"] });
      await queryClient.invalidateQueries({ queryKey: ["ledger-totals"] });
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  if (entryQuery.isLoading)
    return <p className="muted">Loading ledger entry…</p>;
  if (entryQuery.isError) {
    return <ErrorBanner message={getErrorMessage(entryQuery.error)} />;
  }
  const entry = entryQuery.data;
  if (!entry) return null;

  const canWrite = !entry.is_archived;

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <div className="page-toolbar">
        <div>
          <h1>
            {typeLabel(entry.entry_type)} · {entry.amount}
          </h1>
          <p className="lede">
            {entry.occurred_at} · {categoryLabel(entry.category)}
            {entry.is_archived ? " · Archived" : ""}
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
                    "Archive this ledger entry? It will leave the active list and totals.",
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
        <LedgerEntryForm
          key={entry.updated_at}
          mode="edit"
          initial={entry}
          submitLabel="Save changes"
          pending={updateMutation.isPending}
          onSubmit={(input) =>
            updateMutation.mutate(input as LedgerEntryUpdateInput)
          }
        />
      ) : (
        <dl className="detail-grid">
          <div>
            <dt>Type</dt>
            <dd>{typeLabel(entry.entry_type)}</dd>
          </div>
          <div>
            <dt>Date</dt>
            <dd>{entry.occurred_at}</dd>
          </div>
          <div>
            <dt>Category</dt>
            <dd>{categoryLabel(entry.category)}</dd>
          </div>
          <div>
            <dt>Amount</dt>
            <dd>{entry.amount}</dd>
          </div>
          <div>
            <dt>Total price</dt>
            <dd>{entry.total_price}</dd>
          </div>
          <div>
            <dt>Unit</dt>
            <dd>{entry.unit ?? "—"}</dd>
          </div>
          <div className="detail-span">
            <dt>Note</dt>
            <dd>{entry.note ?? "—"}</dd>
          </div>
        </dl>
      )}

      {!canWrite ? (
        <p className="muted">This entry is archived and cannot be edited.</p>
      ) : null}
    </div>
  );
}
