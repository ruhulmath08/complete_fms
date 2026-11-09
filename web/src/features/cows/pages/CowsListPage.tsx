import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { listCows } from '../api/cowsApi'
import { getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

export function CowsListPage() {
  const [includeArchived, setIncludeArchived] = useState(false)
  const query = useQuery({
    queryKey: ['cows', { includeArchived }],
    queryFn: () => listCows({ include_archived: includeArchived, limit: 100 }),
  })

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <div className="page-toolbar">
        <div>
          <h1>Cows</h1>
          <p className="lede">Active herd records for milk and feeding.</p>
        </div>
        <Link className="btn btn-primary" to="/cows/new">
          Add cow
        </Link>
      </div>

      <label className="checkbox-row">
        <input
          type="checkbox"
          checked={includeArchived}
          onChange={(e) => setIncludeArchived(e.target.checked)}
        />
        Include archived
      </label>

      {query.isError ? <ErrorBanner message={getErrorMessage(query.error)} /> : null}
      {query.isLoading ? <p className="muted">Loading cows…</p> : null}

      {query.data && query.data.items.length === 0 ? (
        <p className="muted">No cows yet. Add your first cow to get started.</p>
      ) : null}

      {query.data && query.data.items.length > 0 ? (
        <ul className="record-list">
          {query.data.items.map((cow) => (
            <li key={cow.id}>
              <Link to={`/cows/${cow.id}`} className="record-card">
                <div>
                  <strong>{cow.tag_number}</strong>
                  {cow.name ? <span className="muted"> · {cow.name}</span> : null}
                  {cow.is_archived ? (
                    <span className="badge badge-muted">Archived</span>
                  ) : null}
                </div>
                <div className="muted">
                  {cow.purpose} · {cow.gender}
                </div>
              </Link>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  )
}
