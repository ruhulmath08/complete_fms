import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { listPoultryGroups } from '../api/poultryApi'
import { getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

export function PoultryListPage() {
  const [includeArchived, setIncludeArchived] = useState(false)
  const query = useQuery({
    queryKey: ['poultry-groups', { includeArchived }],
    queryFn: () =>
      listPoultryGroups({ include_archived: includeArchived, limit: 100 }),
  })

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <div className="page-toolbar">
        <div>
          <h1>Poultry</h1>
          <p className="lede">Groups for broilers, ducks, layers, and local birds.</p>
        </div>
        <Link className="btn btn-primary" to="/poultry/new">
          Add group
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
      {query.isLoading ? <p className="muted">Loading poultry groups…</p> : null}

      {query.data && query.data.items.length === 0 ? (
        <p className="muted">No poultry groups yet. Add your first group to get started.</p>
      ) : null}

      {query.data && query.data.items.length > 0 ? (
        <ul className="record-list">
          {query.data.items.map((group) => (
            <li key={group.id}>
              <Link to={`/poultry/${group.id}`} className="record-card">
                <div>
                  <strong>{group.name}</strong>
                  {group.is_archived ? (
                    <span className="badge badge-muted">Archived</span>
                  ) : null}
                </div>
                <div className="muted">
                  {group.poultry_type} · {group.bird_count} birds
                </div>
              </Link>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  )
}
