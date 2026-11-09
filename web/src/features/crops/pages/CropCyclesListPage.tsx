import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { listCropCycles, listCropNames } from '../api/cropsApi'
import { getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

export function CropCyclesListPage() {
  const [includeArchived, setIncludeArchived] = useState(false)
  const cyclesQuery = useQuery({
    queryKey: ['crop-cycles', { includeArchived }],
    queryFn: () =>
      listCropCycles({ include_archived: includeArchived, limit: 100 }),
  })
  const namesQuery = useQuery({
    queryKey: ['crop-names', { includeArchived: true }],
    queryFn: () => listCropNames({ include_archived: true, limit: 100 }),
  })

  const nameById = useMemo(() => {
    const map = new Map<string, string>()
    for (const name of namesQuery.data?.items ?? []) {
      map.set(name.id, name.name)
    }
    return map
  }, [namesQuery.data])

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <div className="page-toolbar">
        <div>
          <h1>Crops</h1>
          <p className="lede">Planting cycles, expenses, harvests, and results.</p>
        </div>
        <div className="toolbar-actions">
          <Link className="btn btn-ghost" to="/crops/names">
            Crop names
          </Link>
          <Link className="btn btn-primary" to="/crops/cycles/new">
            Add cycle
          </Link>
        </div>
      </div>

      <label className="checkbox-row">
        <input
          type="checkbox"
          checked={includeArchived}
          onChange={(e) => setIncludeArchived(e.target.checked)}
        />
        Include archived
      </label>

      {cyclesQuery.isError ? (
        <ErrorBanner message={getErrorMessage(cyclesQuery.error)} />
      ) : null}
      {cyclesQuery.isLoading ? <p className="muted">Loading crop cycles…</p> : null}

      {cyclesQuery.data && cyclesQuery.data.items.length === 0 ? (
        <p className="muted">
          No crop cycles yet. Add a crop name, then start your first cycle.
        </p>
      ) : null}

      {cyclesQuery.data && cyclesQuery.data.items.length > 0 ? (
        <ul className="record-list">
          {cyclesQuery.data.items.map((cycle) => (
            <li key={cycle.id}>
              <Link to={`/crops/cycles/${cycle.id}`} className="record-card">
                <div>
                  <strong>
                    {nameById.get(cycle.crop_name_id) ?? 'Crop'}
                    {cycle.plot_name ? ` · ${cycle.plot_name}` : ''}
                  </strong>
                  {cycle.is_archived ? (
                    <span className="badge badge-muted">Archived</span>
                  ) : null}
                </div>
                <div className="muted">
                  Planted {cycle.planted_at}
                  {cycle.location ? ` · ${cycle.location}` : ''}
                </div>
              </Link>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  )
}
