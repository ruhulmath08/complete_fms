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
        <div className="table-responsive">
          <table className="table table-striped">
            <thead>
              <tr>
                <th scope="col">Tag</th>
                <th scope="col">Name</th>
                <th scope="col">Purpose</th>
                <th scope="col">Gender</th>
                <th scope="col">Status</th>
              </tr>
            </thead>
            <tbody>
              {query.data.items.map((cow) => (
                <tr key={cow.id}>
                  <td>
                    <Link to={`/cows/${cow.id}`}>{cow.tag_number}</Link>
                  </td>
                  <td>{cow.name ?? '—'}</td>
                  <td>{cow.purpose}</td>
                  <td>{cow.gender}</td>
                  <td>{cow.is_archived ? 'Archived' : 'Active'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : null}
    </div>
  )
}
