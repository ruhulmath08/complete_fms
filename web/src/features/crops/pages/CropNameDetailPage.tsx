import { useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { archiveCropName, getCropName, updateCropName } from '../api/cropsApi'
import { CropNameForm } from '../components/CropNameForm'
import type { CropNameCreateInput } from '../types'
import { ApiError, getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

export function CropNameDetailPage() {
  const { cropNameId = '' } = useParams()
  const queryClient = useQueryClient()
  const [error, setError] = useState<string | null>(null)
  const [editing, setEditing] = useState(false)

  const nameQuery = useQuery({
    queryKey: ['crop-name', cropNameId],
    queryFn: () => getCropName(cropNameId),
    enabled: Boolean(cropNameId),
  })

  const updateMutation = useMutation({
    mutationFn: (input: CropNameCreateInput) => updateCropName(cropNameId, input),
    onSuccess: async () => {
      setEditing(false)
      setError(null)
      await queryClient.invalidateQueries({ queryKey: ['crop-name', cropNameId] })
      await queryClient.invalidateQueries({ queryKey: ['crop-names'] })
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  const archiveMutation = useMutation({
    mutationFn: () => archiveCropName(cropNameId),
    onSuccess: async () => {
      setEditing(false)
      setError(null)
      await queryClient.invalidateQueries({ queryKey: ['crop-name', cropNameId] })
      await queryClient.invalidateQueries({ queryKey: ['crop-names'] })
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  if (nameQuery.isLoading) return <p className="muted">Loading crop name…</p>
  if (nameQuery.isError) {
    return <ErrorBanner message={getErrorMessage(nameQuery.error)} />
  }
  const cropName = nameQuery.data
  if (!cropName) return null

  const canWrite = !cropName.is_archived

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <p className="muted">
        <Link to="/crops/names">← Back to crop names</Link>
      </p>
      <div className="page-toolbar">
        <div>
          <h1>{cropName.name}</h1>
          <p className="lede">
            Crop catalog entry
            {cropName.is_archived ? ' · Archived' : ''}
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
                    'Archive this crop name? It will leave the active catalog.',
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
        <CropNameForm
          key={cropName.updated_at}
          initial={cropName}
          submitLabel="Save changes"
          pending={updateMutation.isPending}
          onSubmit={(input) => updateMutation.mutate(input)}
        />
      ) : (
        <dl className="detail-grid">
          <div>
            <dt>Name</dt>
            <dd>{cropName.name}</dd>
          </div>
          <div className="detail-span">
            <dt>Notes</dt>
            <dd>{cropName.notes ?? '—'}</dd>
          </div>
        </dl>
      )}
    </div>
  )
}
