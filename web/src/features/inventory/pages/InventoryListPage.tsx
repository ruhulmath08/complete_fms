import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { listInventoryItems } from '../api/inventoryApi'
import { INVENTORY_CATEGORIES } from '../types'
import { getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

function categoryLabel(category: string): string {
  return (
    INVENTORY_CATEGORIES.find((item) => item.value === category)?.label ?? category
  )
}

export function InventoryListPage() {
  const [includeArchived, setIncludeArchived] = useState(false)
  const query = useQuery({
    queryKey: ['inventory-items', { includeArchived }],
    queryFn: () =>
      listInventoryItems({ include_archived: includeArchived, limit: 100 }),
  })

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <div className="page-toolbar">
        <div>
          <h1>Inventory</h1>
          <p className="lede">Supplies on hand with stock add and use updates.</p>
        </div>
        <Link className="btn btn-primary" to="/inventory/new">
          Add item
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
      {query.isLoading ? <p className="muted">Loading inventory…</p> : null}

      {query.data && query.data.items.length === 0 ? (
        <p className="muted">No inventory items yet. Add feed, fertilizer, or supplies.</p>
      ) : null}

      {query.data && query.data.items.length > 0 ? (
        <ul className="record-list">
          {query.data.items.map((item) => (
            <li key={item.id}>
              <Link to={`/inventory/${item.id}`} className="record-card">
                <div>
                  <strong>{item.name}</strong>
                  {item.is_archived ? (
                    <span className="badge badge-muted">Archived</span>
                  ) : null}
                </div>
                <div className="muted">
                  {categoryLabel(item.category)} · {item.quantity} {item.unit} · total{' '}
                  {item.total_price}
                </div>
              </Link>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  )
}
