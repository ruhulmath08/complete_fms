import { useState, type FormEvent } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  addFeeding,
  addMilkProduction,
  archiveCow,
  getCow,
  getSuggestedUnits,
  listFeedings,
  listMilkProductions,
  updateCow,
  uploadCowImage,
} from '../api/cowsApi'
import { CowForm } from '../components/CowForm'
import { PaginationControls } from '../components/PaginationControls'
import { useCowImageUrl } from '../hooks/useCowImageUrl'
import type { CowCreateInput } from '../types'
import { ApiError, getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

const PAGE_SIZE = 10

function toDateTimeLocalValue(iso: string): string {
  const date = new Date(iso)
  if (Number.isNaN(date.getTime())) return ''
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`
}

function fromDateTimeLocalValue(value: string): string {
  return new Date(value).toISOString()
}

function milkTotal(quantity: string, pricePerUnit: string): string {
  const qty = Number(quantity)
  const price = Number(pricePerUnit)
  if (Number.isNaN(qty) || Number.isNaN(price)) return '—'
  return (qty * price).toFixed(2)
}

function MilkSection({
  cowId,
  canAdd,
}: {
  cowId: string
  canAdd: boolean
}) {
  const queryClient = useQueryClient()
  const [error, setError] = useState<string | null>(null)
  const [offset, setOffset] = useState(0)
  const [producedAt, setProducedAt] = useState(() =>
    toDateTimeLocalValue(new Date().toISOString()),
  )
  const [quantity, setQuantity] = useState('')
  const [unit, setUnit] = useState('L')
  const [pricePerUnit, setPricePerUnit] = useState('0')
  const [note, setNote] = useState('')

  const listQuery = useQuery({
    queryKey: ['milk', cowId, offset],
    queryFn: () => listMilkProductions(cowId, { limit: PAGE_SIZE, offset }),
  })
  const unitsQuery = useQuery({
    queryKey: ['suggested-units'],
    queryFn: getSuggestedUnits,
  })

  const mutation = useMutation({
    mutationFn: () =>
      addMilkProduction(cowId, {
        produced_at: fromDateTimeLocalValue(producedAt),
        quantity,
        unit,
        price_per_unit: pricePerUnit,
        note: note.trim() || null,
      }),
    onSuccess: async () => {
      setQuantity('')
      setNote('')
      setError(null)
      setOffset(0)
      await queryClient.invalidateQueries({ queryKey: ['milk', cowId] })
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

  const items = listQuery.data?.items ?? []
  const meta = listQuery.data?.meta

  return (
    <section className="detail-section">
      <h2>Milk production</h2>
      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.isLoading ? <p className="muted">Loading milk entries…</p> : null}
      {!listQuery.isLoading && items.length === 0 ? (
        <p className="muted">No milk entries yet.</p>
      ) : null}
      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">No</th>
                  <th scope="col">Date + time</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Unit price</th>
                  <th scope="col">Total</th>
                  <th scope="col">Note</th>
                </tr>
              </thead>
              <tbody>
                {items.map((row, index) => (
                  <tr key={row.id}>
                    <td>{offset + index + 1}</td>
                    <td>{new Date(row.produced_at).toLocaleString()}</td>
                    <td>
                      {row.quantity} {row.unit}
                    </td>
                    <td>{row.price_per_unit}</td>
                    <td>{milkTotal(row.quantity, row.price_per_unit)}</td>
                    <td>{row.note ?? '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {meta ? (
            <PaginationControls
              label="Milk"
              total={meta.total}
              limit={meta.limit}
              offset={meta.offset}
              onOffsetChange={setOffset}
            />
          ) : null}
        </>
      ) : null}

      {canAdd ? (
        <>
          <ErrorBanner message={error} />
          <form className="form-stack" onSubmit={onSubmit}>
            <div className="row-2">
              <div className="field">
                <label htmlFor="produced_at">Produced at</label>
                <input
                  id="produced_at"
                  type="datetime-local"
                  value={producedAt}
                  onChange={(e) => setProducedAt(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="milk_quantity">Quantity</label>
                <input
                  id="milk_quantity"
                  value={quantity}
                  onChange={(e) => setQuantity(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="row-2">
              <div className="field">
                <label htmlFor="milk_unit">Unit</label>
                <input
                  id="milk_unit"
                  list="unit-suggestions"
                  value={unit}
                  onChange={(e) => setUnit(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="price_per_unit">Price per unit</label>
                <input
                  id="price_per_unit"
                  value={pricePerUnit}
                  onChange={(e) => setPricePerUnit(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="field">
              <label htmlFor="milk_note">Note</label>
              <input id="milk_note" value={note} onChange={(e) => setNote(e.target.value)} />
            </div>
            <datalist id="unit-suggestions">
              {(unitsQuery.data ?? []).map((u) => (
                <option key={u} value={u} />
              ))}
            </datalist>
            <button className="btn btn-primary" type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? 'Saving…' : 'Add milk entry'}
            </button>
          </form>
        </>
      ) : (
        <p className="muted">Milk recording is unavailable for this cow.</p>
      )}
    </section>
  )
}

function FeedingSection({ cowId, canAdd }: { cowId: string; canAdd: boolean }) {
  const queryClient = useQueryClient()
  const [error, setError] = useState<string | null>(null)
  const [offset, setOffset] = useState(0)
  const [fedAt, setFedAt] = useState(() => toDateTimeLocalValue(new Date().toISOString()))
  const [feedName, setFeedName] = useState('')
  const [quantity, setQuantity] = useState('')
  const [unit, setUnit] = useState('kg')
  const [note, setNote] = useState('')

  const listQuery = useQuery({
    queryKey: ['feedings', cowId, offset],
    queryFn: () => listFeedings(cowId, { limit: PAGE_SIZE, offset }),
  })
  const unitsQuery = useQuery({
    queryKey: ['suggested-units'],
    queryFn: getSuggestedUnits,
  })

  const mutation = useMutation({
    mutationFn: () =>
      addFeeding(cowId, {
        fed_at: fromDateTimeLocalValue(fedAt),
        feed_name: feedName,
        quantity,
        unit,
        note: note.trim() || null,
      }),
    onSuccess: async () => {
      setFeedName('')
      setQuantity('')
      setNote('')
      setError(null)
      setOffset(0)
      await queryClient.invalidateQueries({ queryKey: ['feedings', cowId] })
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

  const items = listQuery.data?.items ?? []
  const meta = listQuery.data?.meta

  return (
    <section className="detail-section">
      <h2>Feeding</h2>
      {listQuery.isError ? (
        <ErrorBanner message={getErrorMessage(listQuery.error)} />
      ) : null}
      {listQuery.isLoading ? <p className="muted">Loading feeding entries…</p> : null}
      {!listQuery.isLoading && items.length === 0 ? (
        <p className="muted">No feeding entries yet.</p>
      ) : null}
      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">No</th>
                  <th scope="col">Date + time</th>
                  <th scope="col">Feed name</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Unit</th>
                  <th scope="col">Note</th>
                </tr>
              </thead>
              <tbody>
                {items.map((row, index) => (
                  <tr key={row.id}>
                    <td>{offset + index + 1}</td>
                    <td>{new Date(row.fed_at).toLocaleString()}</td>
                    <td>{row.feed_name}</td>
                    <td>{row.quantity}</td>
                    <td>{row.unit}</td>
                    <td>{row.note ?? '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {meta ? (
            <PaginationControls
              label="Feeding"
              total={meta.total}
              limit={meta.limit}
              offset={meta.offset}
              onOffsetChange={setOffset}
            />
          ) : null}
        </>
      ) : null}

      {canAdd ? (
        <>
          <ErrorBanner message={error} />
          <form className="form-stack" onSubmit={onSubmit}>
            <div className="row-2">
              <div className="field">
                <label htmlFor="fed_at">Fed at</label>
                <input
                  id="fed_at"
                  type="datetime-local"
                  value={fedAt}
                  onChange={(e) => setFedAt(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="feed_name">Feed name</label>
                <input
                  id="feed_name"
                  value={feedName}
                  onChange={(e) => setFeedName(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="row-2">
              <div className="field">
                <label htmlFor="feed_quantity">Quantity</label>
                <input
                  id="feed_quantity"
                  value={quantity}
                  onChange={(e) => setQuantity(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="feed_unit">Unit</label>
                <input
                  id="feed_unit"
                  list="feed-unit-suggestions"
                  value={unit}
                  onChange={(e) => setUnit(e.target.value)}
                  required
                />
              </div>
            </div>
            <div className="field">
              <label htmlFor="feed_note">Note</label>
              <input id="feed_note" value={note} onChange={(e) => setNote(e.target.value)} />
            </div>
            <datalist id="feed-unit-suggestions">
              {(unitsQuery.data ?? []).map((u) => (
                <option key={u} value={u} />
              ))}
            </datalist>
            <button className="btn btn-primary" type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? 'Saving…' : 'Add feeding'}
            </button>
          </form>
        </>
      ) : (
        <p className="muted">Feeding cannot be added while this cow is archived.</p>
      )}
    </section>
  )
}

export function CowDetailPage() {
  const { cowId = '' } = useParams()
  const queryClient = useQueryClient()
  const [error, setError] = useState<string | null>(null)
  const [editing, setEditing] = useState(false)

  const cowQuery = useQuery({
    queryKey: ['cow', cowId],
    queryFn: () => getCow(cowId),
    enabled: Boolean(cowId),
  })

  const cow = cowQuery.data
  const imageUrl = useCowImageUrl(cow?.id, cow?.image_url)

  const updateMutation = useMutation({
    mutationFn: async ({
      input,
      imageFile,
    }: {
      input: CowCreateInput
      imageFile: File | null
    }) => {
      const updated = await updateCow(cowId, input)
      if (imageFile) {
        return uploadCowImage(cowId, imageFile)
      }
      return updated
    },
    onSuccess: async () => {
      setEditing(false)
      setError(null)
      await queryClient.invalidateQueries({ queryKey: ['cow', cowId] })
      await queryClient.invalidateQueries({ queryKey: ['cows'] })
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  const archiveMutation = useMutation({
    mutationFn: () => archiveCow(cowId),
    onSuccess: async () => {
      setEditing(false)
      setError(null)
      await queryClient.invalidateQueries({ queryKey: ['cow', cowId] })
      await queryClient.invalidateQueries({ queryKey: ['cows'] })
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  if (cowQuery.isLoading) return <p className="muted">Loading cow…</p>
  if (cowQuery.isError) {
    return <ErrorBanner message={getErrorMessage(cowQuery.error)} />
  }
  if (!cow) return null

  const milkEligible = cow.purpose === 'milk' || cow.purpose === 'both'
  const canWrite = !cow.is_archived

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <p className="muted">
        <Link to="/cows">← Back to cows</Link>
      </p>
      <div className="page-toolbar">
        <div>
          <h1>
            {cow.tag_number}
            {cow.name ? ` · ${cow.name}` : ''}
          </h1>
          <p className="lede">
            {cow.purpose} · {cow.gender}
            {cow.is_archived ? ' · Archived' : ''}
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
                if (window.confirm('Archive this cow? It will leave the active list.')) {
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

      {!editing && imageUrl ? (
        <img src={imageUrl} alt="" className="profile-preview" />
      ) : null}

      {editing && canWrite ? (
        <CowForm
          key={cow.updated_at}
          initial={cow}
          submitLabel="Save changes"
          pending={updateMutation.isPending}
          onSubmit={(input, imageFile) => updateMutation.mutate({ input, imageFile })}
        />
      ) : (
        <dl className="detail-grid">
          <div>
            <dt>Breed</dt>
            <dd>{cow.breed ?? '—'}</dd>
          </div>
          <div>
            <dt>Color</dt>
            <dd>{cow.color ?? '—'}</dd>
          </div>
          <div>
            <dt>Date of birth</dt>
            <dd>{cow.date_of_birth ?? '—'}</dd>
          </div>
          <div>
            <dt>Age</dt>
            <dd>{cow.age ?? '—'}</dd>
          </div>
          <div>
            <dt>Weight (kg)</dt>
            <dd>{cow.weight ?? '—'}</dd>
          </div>
          <div>
            <dt>Acquired by</dt>
            <dd>{cow.acquired_by}</dd>
          </div>
          {cow.acquired_by === 'purchased' ? (
            <>
              <div>
                <dt>Purchase date</dt>
                <dd>{cow.purchase_date ?? '—'}</dd>
              </div>
              <div>
                <dt>Purchase price</dt>
                <dd>{cow.purchase_price ?? '—'}</dd>
              </div>
            </>
          ) : null}
          <div className="detail-span">
            <dt>Notes</dt>
            <dd>{cow.notes ?? '—'}</dd>
          </div>
        </dl>
      )}

      {milkEligible ? (
        <MilkSection cowId={cow.id} canAdd={canWrite} />
      ) : (
        <section className="detail-section">
          <h2>Milk production</h2>
          <p className="muted">Meat-purpose cows do not record milk.</p>
        </section>
      )}

      <FeedingSection cowId={cow.id} canAdd={canWrite} />
    </div>
  )
}
