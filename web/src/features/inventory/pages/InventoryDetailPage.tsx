import { useState, type FormEvent } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  addStockUpdate,
  archiveInventoryItem,
  getInventoryItem,
  listStockUpdates,
  updateInventoryItem,
} from '../api/inventoryApi'
import { InventoryItemForm } from '../components/InventoryItemForm'
import {
  INVENTORY_CATEGORIES,
  type InventoryItemUpdateInput,
  type StockChangeType,
} from '../types'
import { ApiError, getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

function categoryLabel(category: string): string {
  return (
    INVENTORY_CATEGORIES.find((item) => item.value === category)?.label ?? category
  )
}

function StockUpdatesSection({
  itemId,
  canAdd,
}: {
  itemId: string
  canAdd: boolean
}) {
  const queryClient = useQueryClient()
  const [error, setError] = useState<string | null>(null)
  const [occurredAt, setOccurredAt] = useState(() =>
    new Date().toISOString().slice(0, 10),
  )
  const [changeType, setChangeType] = useState<StockChangeType>('add')
  const [quantityChange, setQuantityChange] = useState('')
  const [reason, setReason] = useState('')

  const listQuery = useQuery({
    queryKey: ['stock-updates', itemId],
    queryFn: () => listStockUpdates(itemId, { limit: 50 }),
  })

  const mutation = useMutation({
    mutationFn: () =>
      addStockUpdate(itemId, {
        occurred_at: occurredAt,
        change_type: changeType,
        quantity_change: quantityChange,
        reason: reason.trim() || null,
      }),
    onSuccess: async () => {
      setQuantityChange('')
      setReason('')
      setError(null)
      await queryClient.invalidateQueries({ queryKey: ['stock-updates', itemId] })
      await queryClient.invalidateQueries({ queryKey: ['inventory-item', itemId] })
      await queryClient.invalidateQueries({ queryKey: ['inventory-items'] })
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  function onSubmit(event: FormEvent) {
    event.preventDefault()
    setError(null)
    mutation.mutate()
  }

  return (
    <section className="detail-section">
      <h2>Stock updates</h2>
      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.data?.items.length ? (
        <ul className="simple-list">
          {listQuery.data.items.map((row) => (
            <li key={row.id}>
              <strong>
                {row.change_type}: {row.quantity_change}
              </strong>
              <span className="muted"> · {row.occurred_at}</span>
              {row.reason ? <div className="muted">{row.reason}</div> : null}
            </li>
          ))}
        </ul>
      ) : (
        <p className="muted">No stock updates yet.</p>
      )}

      {canAdd ? (
        <>
          <ErrorBanner message={error} />
          <form className="form-stack" onSubmit={onSubmit}>
            <div className="row-2">
              <div className="field">
                <label htmlFor="occurred_at">Occurred at</label>
                <input
                  id="occurred_at"
                  type="date"
                  value={occurredAt}
                  onChange={(e) => setOccurredAt(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="change_type">Change type</label>
                <select
                  id="change_type"
                  value={changeType}
                  onChange={(e) => setChangeType(e.target.value as StockChangeType)}
                >
                  <option value="add">Add</option>
                  <option value="use">Use</option>
                </select>
              </div>
            </div>
            <div className="row-2">
              <div className="field">
                <label htmlFor="quantity_change">Quantity change</label>
                <input
                  id="quantity_change"
                  inputMode="decimal"
                  value={quantityChange}
                  onChange={(e) => setQuantityChange(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="stock_reason">Reason</label>
                <input
                  id="stock_reason"
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                />
              </div>
            </div>
            <button className="btn btn-primary" type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? 'Saving…' : 'Add stock update'}
            </button>
          </form>
        </>
      ) : (
        <p className="muted">Stock updates cannot be added while this item is archived.</p>
      )}
    </section>
  )
}

export function InventoryDetailPage() {
  const { itemId = '' } = useParams()
  const queryClient = useQueryClient()
  const [error, setError] = useState<string | null>(null)
  const [editing, setEditing] = useState(false)

  const itemQuery = useQuery({
    queryKey: ['inventory-item', itemId],
    queryFn: () => getInventoryItem(itemId),
    enabled: Boolean(itemId),
  })

  const updateMutation = useMutation({
    mutationFn: (input: InventoryItemUpdateInput) =>
      updateInventoryItem(itemId, input),
    onSuccess: async () => {
      setEditing(false)
      setError(null)
      await queryClient.invalidateQueries({ queryKey: ['inventory-item', itemId] })
      await queryClient.invalidateQueries({ queryKey: ['inventory-items'] })
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  const archiveMutation = useMutation({
    mutationFn: () => archiveInventoryItem(itemId),
    onSuccess: async () => {
      setEditing(false)
      setError(null)
      await queryClient.invalidateQueries({ queryKey: ['inventory-item', itemId] })
      await queryClient.invalidateQueries({ queryKey: ['inventory-items'] })
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  if (itemQuery.isLoading) return <p className="muted">Loading inventory item…</p>
  if (itemQuery.isError) {
    return <ErrorBanner message={getErrorMessage(itemQuery.error)} />
  }
  const item = itemQuery.data
  if (!item) return null

  const canWrite = !item.is_archived

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <p className="muted">
        <Link to="/inventory">← Back to inventory</Link>
      </p>
      <div className="page-toolbar">
        <div>
          <h1>{item.name}</h1>
          <p className="lede">
            {categoryLabel(item.category)} · {item.quantity} {item.unit}
            {item.is_archived ? ' · Archived' : ''}
          </p>
        </div>
        {canWrite ? (
          <div className="toolbar-actions">
            <button
              type="button"
              className="btn btn-ghost"
              onClick={() => setEditing((v) => !v)}
            >
              {editing ? 'Cancel edit' : 'Edit'}
            </button>
            <button
              type="button"
              className="btn btn-ghost"
              disabled={archiveMutation.isPending}
              onClick={() => {
                if (
                  window.confirm(
                    'Archive this inventory item? It will leave the active list.',
                  )
                ) {
                  archiveMutation.mutate()
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
        <InventoryItemForm
          key={item.updated_at}
          mode="edit"
          initial={item}
          submitLabel="Save changes"
          pending={updateMutation.isPending}
          onSubmit={(input) =>
            updateMutation.mutate(input as InventoryItemUpdateInput)
          }
        />
      ) : (
        <dl className="detail-grid">
          <div>
            <dt>Category</dt>
            <dd>{categoryLabel(item.category)}</dd>
          </div>
          <div>
            <dt>Quantity</dt>
            <dd>
              {item.quantity} {item.unit}
            </dd>
          </div>
          <div>
            <dt>Price per unit</dt>
            <dd>{item.price_per_unit}</dd>
          </div>
          <div>
            <dt>Total price</dt>
            <dd>{item.total_price}</dd>
          </div>
          <div className="detail-span">
            <dt>Note</dt>
            <dd>{item.note ?? '—'}</dd>
          </div>
        </dl>
      )}

      <StockUpdatesSection itemId={item.id} canAdd={canWrite} />
    </div>
  )
}
