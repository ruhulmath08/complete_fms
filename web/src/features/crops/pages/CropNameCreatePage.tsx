import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createCropName } from '../api/cropsApi'
import { CropNameForm } from '../components/CropNameForm'
import type { CropNameCreateInput } from '../types'
import { ApiError, getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

export function CropNameCreatePage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [error, setError] = useState<string | null>(null)

  const mutation = useMutation({
    mutationFn: createCropName,
    onSuccess: async (name) => {
      await queryClient.invalidateQueries({ queryKey: ['crop-names'] })
      navigate(`/crops/names/${name.id}`)
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  function onSubmit(input: CropNameCreateInput) {
    setError(null)
    mutation.mutate(input)
  }

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <p className="muted">
        <Link to="/crops/names">← Back to crop names</Link>
      </p>
      <h1>Add crop name</h1>
      <p className="lede">Active names must be unique on your farm.</p>
      <ErrorBanner message={error} />
      <CropNameForm
        submitLabel="Create crop name"
        pending={mutation.isPending}
        onSubmit={onSubmit}
      />
    </div>
  )
}
