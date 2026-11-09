import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { getPeriodTotals, listLedgerEntries } from '../api/ledgerApi'
import { ENTRY_CATEGORIES, ENTRY_TYPES } from '../types'
import { getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

function typeLabel(value: string): string {
  return ENTRY_TYPES.find((item) => item.value === value)?.label ?? value
}

function categoryLabel(value: string): string {
  return ENTRY_CATEGORIES.find((item) => item.value === value)?.label ?? value
}

function monthBounds(): { from: string; to: string } {
  const now = new Date()
  const from = new Date(now.getFullYear(), now.getMonth(), 1)
    .toISOString()
    .slice(0, 10)
  const to = new Date(now.getFullYear(), now.getMonth() + 1, 0)
    .toISOString()
    .slice(0, 10)
  return { from, to }
}

export function LedgerListPage() {
  const defaults = useMemo(() => monthBounds(), [])
  const [includeArchived, setIncludeArchived] = useState(false)
  const [from, setFrom] = useState(defaults.from)
  const [to, setTo] = useState(defaults.to)
  const [appliedFrom, setAppliedFrom] = useState(defaults.from)
  const [appliedTo, setAppliedTo] = useState(defaults.to)

  const listQuery = useQuery({
    queryKey: ['ledger-entries', { includeArchived, appliedFrom, appliedTo }],
    queryFn: () =>
      listLedgerEntries({
        include_archived: includeArchived,
        from: appliedFrom,
        to: appliedTo,
        limit: 100,
      }),
  })

  const totalsQuery = useQuery({
    queryKey: ['ledger-totals', { appliedFrom, appliedTo }],
    queryFn: () => getPeriodTotals({ from: appliedFrom, to: appliedTo }),
  })

  function applyRange() {
    setAppliedFrom(from)
    setAppliedTo(to)
  }

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <div className="page-toolbar">
        <div>
          <h1>Income &amp; expenses</h1>
          <p className="lede">
            General farm ledger entries and period totals (not crop-cycle costs).
          </p>
        </div>
        <Link className="btn btn-primary" to="/ledger/new">
          Add entry
        </Link>
      </div>

      <div className="row-2" style={{ alignItems: 'end', marginBottom: '1rem' }}>
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

      <label className="checkbox-row">
        <input
          type="checkbox"
          checked={includeArchived}
          onChange={(e) => setIncludeArchived(e.target.checked)}
        />
        Include archived
      </label>

      {totalsQuery.isError ? (
        <ErrorBanner message={getErrorMessage(totalsQuery.error)} />
      ) : null}
      {totalsQuery.data ? (
        <dl className="detail-grid" style={{ marginTop: '1rem' }}>
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
      {listQuery.isLoading ? <p className="muted">Loading entries…</p> : null}

      {listQuery.data && listQuery.data.items.length === 0 ? (
        <p className="muted">No ledger entries in this range.</p>
      ) : null}

      {listQuery.data && listQuery.data.items.length > 0 ? (
        <ul className="record-list">
          {listQuery.data.items.map((entry) => (
            <li key={entry.id}>
              <Link to={`/ledger/${entry.id}`} className="record-card">
                <div>
                  <strong>
                    {typeLabel(entry.entry_type)} · {entry.amount}
                  </strong>
                  {entry.is_archived ? (
                    <span className="badge badge-muted">Archived</span>
                  ) : null}
                </div>
                <div className="muted">
                  {entry.occurred_at} · {categoryLabel(entry.category)}
                  {entry.unit ? ` · ${entry.unit}` : ''}
                </div>
              </Link>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  )
}
