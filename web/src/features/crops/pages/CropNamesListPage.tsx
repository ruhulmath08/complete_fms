import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { listCropNames } from '../api/cropsApi'
import { getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

export function CropNamesListPage() {
  const [includeArchived, setIncludeArchived] = useState(false)
  const query = useQuery({
    queryKey: ['crop-names', { includeArchived }],
    queryFn: () =>
      listCropNames({ include_archived: includeArchived, limit: 100 }),
  })

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <p className="muted">
        <Link to="/crops">← Back to cycles</Link>
      </p>
      <div className="page-toolbar">
        <div>
          <h1>Crop names</h1>
          <p className="lede">Catalog of crops you plant. Active names must be unique.</p>
        </div>
        <Link className="btn btn-primary" to="/crops/names/new">
          Add crop name
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
      {query.isLoading ? <p className="muted">Loading crop names…</p> : null}

      {query.data && query.data.items.length === 0 ? (
        <p className="muted">No crop names yet. Add rice, maize, or another crop to start.</p>
      ) : null}

      {query.data && query.data.items.length > 0 ? (
        <ul className="record-list">
          {query.data.items.map((name) => (
            <li key={name.id}>
              <Link to={`/crops/names/${name.id}`} className="record-card">
                <div>
                  <strong>{name.name}</strong>
                  {name.is_archived ? (
                    <span className="badge badge-muted">Archived</span>
                  ) : null}
                </div>
                {name.notes ? <div className="muted">{name.notes}</div> : null}
              </Link>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  )
}
