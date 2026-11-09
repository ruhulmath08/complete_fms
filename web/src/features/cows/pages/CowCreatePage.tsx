import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createCow } from '../api/cowsApi'
import { CowForm } from '../components/CowForm'
import type { CowCreateInput } from '../types'
import { ApiError, getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

export function CowCreatePage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [error, setError] = useState<string | null>(null)

  const mutation = useMutation({
    mutationFn: createCow,
    onSuccess: async (cow) => {
      await queryClient.invalidateQueries({ queryKey: ['cows'] })
      navigate(`/cows/${cow.id}`)
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  function onSubmit(input: CowCreateInput) {
    setError(null)
    mutation.mutate(input)
  }

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <p className="muted">
        <Link to="/cows">← Back to cows</Link>
      </p>
      <h1>Add cow</h1>
      <p className="lede">Create a cow record for your farm.</p>
      <ErrorBanner message={error} />
      <CowForm submitLabel="Create cow" pending={mutation.isPending} onSubmit={onSubmit} />
    </div>
  )
}
