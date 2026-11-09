import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createLedgerEntry } from '../api/ledgerApi'
import { LedgerEntryForm } from '../components/LedgerEntryForm'
import type { LedgerEntryCreateInput } from '../types'
import { ApiError, getErrorMessage } from '../../../shared/api/errors'
import { ErrorBanner } from '../../../shared/ui/ErrorBanner'

export function LedgerCreatePage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [error, setError] = useState<string | null>(null)

  const mutation = useMutation({
    mutationFn: createLedgerEntry,
    onSuccess: async (entry) => {
      await queryClient.invalidateQueries({ queryKey: ['ledger-entries'] })
      await queryClient.invalidateQueries({ queryKey: ['ledger-totals'] })
      navigate(`/ledger/${entry.id}`)
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message)
      else setError(getErrorMessage(err))
    },
  })

  function onSubmit(input: LedgerEntryCreateInput) {
    setError(null)
    mutation.mutate(input)
  }

  return (
    <div className="panel panel-wide" style={{ margin: '0 auto' }}>
      <p className="muted">
        <Link to="/ledger">← Back to ledger</Link>
      </p>
      <h1>Add ledger entry</h1>
      <p className="lede">Record a general income or expense for your farm.</p>
      <ErrorBanner message={error} />
      <LedgerEntryForm
        mode="create"
        submitLabel="Create entry"
        pending={mutation.isPending}
        onSubmit={(input) => onSubmit(input as LedgerEntryCreateInput)}
      />
    </div>
  )
}
