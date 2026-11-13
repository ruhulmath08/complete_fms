import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { getPeriodTotals, listLedgerEntries } from "../api/ledgerApi";
import { LedgerRangeChart } from "../components/LedgerRangeChart";
import { ENTRY_CATEGORIES, ENTRY_TYPES } from "../types";
import { toIsoDate } from "../../../shared/dates";
import { DEFAULT_PAGE_SIZE } from "../../../shared/constants/pagination";
import { getErrorMessage } from "../../../shared/api/errors";
import { EmptyState } from "../../../shared/ui/EmptyState";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { PaginationControls } from "../../../shared/ui/PaginationControls";

function typeLabel(value: string): string {
  return ENTRY_TYPES.find((item) => item.value === value)?.label ?? value;
}

function categoryLabel(value: string): string {
  return ENTRY_CATEGORIES.find((item) => item.value === value)?.label ?? value;
}

function monthBounds(): { from: string; to: string } {
  const now = new Date();
  const from = toIsoDate(new Date(now.getFullYear(), now.getMonth(), 1));
  const to = toIsoDate(new Date(now.getFullYear(), now.getMonth() + 1, 0));
  return { from, to };
}

export function LedgerListPage() {
  const defaults = useMemo(() => monthBounds(), []);
  const [includeArchived, setIncludeArchived] = useState(false);
  const [from, setFrom] = useState(defaults.from);
  const [to, setTo] = useState(defaults.to);
  const [appliedFrom, setAppliedFrom] = useState(defaults.from);
  const [appliedTo, setAppliedTo] = useState(defaults.to);
  const [offset, setOffset] = useState(0);

  const listQuery = useQuery({
    queryKey: [
      "ledger-entries",
      { includeArchived, appliedFrom, appliedTo, offset },
    ],
    queryFn: () =>
      listLedgerEntries({
        include_archived: includeArchived,
        from: appliedFrom,
        to: appliedTo,
        limit: DEFAULT_PAGE_SIZE,
        offset,
      }),
  });

  const totalsQuery = useQuery({
    queryKey: ["ledger-totals", { appliedFrom, appliedTo }],
    queryFn: () => getPeriodTotals({ from: appliedFrom, to: appliedTo }),
  });

  function applyRange() {
    setAppliedFrom(from);
    setAppliedTo(to);
    setOffset(0);
  }

  function onIncludeArchivedChange(checked: boolean) {
    setIncludeArchived(checked);
    setOffset(0);
  }

  const items = listQuery.data?.items ?? [];
  const total = listQuery.data?.meta.total ?? 0;

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <div className="page-toolbar">
        <div>
          <h1>Income &amp; expenses</h1>
          <p className="lede">
            General farm ledger entries and period totals (not crop-cycle
            costs).
          </p>
        </div>
        <Link className="btn btn-primary" to="/ledger/new">
          Add entry
        </Link>
      </div>

      <div
        className="row-2"
        style={{ alignItems: "end", marginBottom: "1rem" }}
      >
        <div className="field">
          <label htmlFor="filter_from">From</label>
          <input
            id="filter_from"
            type="date"
            value={from}
            onChange={(e) => setFrom(e.target.value)}
          />
        </div>
        <div className="field">
          <label htmlFor="filter_to">To</label>
          <input
            id="filter_to"
            type="date"
            value={to}
            onChange={(e) => setTo(e.target.value)}
          />
        </div>
      </div>
      <button type="button" className="btn btn-ghost" onClick={applyRange}>
        Apply date range
      </button>

      <div style={{ marginTop: "1rem" }}>
        <LedgerRangeChart from={appliedFrom} to={appliedTo} />
      </div>

      <label className="checkbox-row">
        <input
          type="checkbox"
          checked={includeArchived}
          onChange={(e) => onIncludeArchivedChange(e.target.checked)}
        />
        Include archived
      </label>

      {totalsQuery.isError ? (
        <ErrorBanner message={getErrorMessage(totalsQuery.error)} />
      ) : null}
      {totalsQuery.data ? (
        <dl className="detail-grid" style={{ marginTop: "1rem" }}>
          <div>
            <dt>Total income</dt>
            <dd>{totalsQuery.data.total_income}</dd>
          </div>
          <div>
            <dt>Total expenses</dt>
            <dd>{totalsQuery.data.total_expenses}</dd>
          </div>
          <div>
            <dt>Net</dt>
            <dd>{totalsQuery.data.net}</dd>
          </div>
        </dl>
      ) : null}

      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.isLoading ? <LoadingState message="Loading entries…" /> : null}

      {!listQuery.isLoading && !listQuery.isError && items.length === 0 ? (
        <EmptyState
          message="No ledger entries in this range."
          action={
            <Link className="btn btn-primary" to="/ledger/new">
              Add entry
            </Link>
          }
        />
      ) : null}

      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">Date</th>
                  <th scope="col">Type</th>
                  <th scope="col">Category</th>
                  <th scope="col">Total</th>
                  <th scope="col">Status</th>
                </tr>
              </thead>
              <tbody>
                {items.map((entry) => (
                  <tr key={entry.id}>
                    <td>
                      <Link to={`/ledger/${entry.id}`}>
                        {entry.occurred_at}
                      </Link>
                    </td>
                    <td>{typeLabel(entry.entry_type)}</td>
                    <td>{categoryLabel(entry.category)}</td>
                    <td>{entry.amount}</td>
                    <td>{entry.is_archived ? "Archived" : "Active"}</td>
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
            label="Ledger entries"
          />
        </>
      ) : null}
    </div>
  );
}
