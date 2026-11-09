import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { ApiError } from '../../../shared/api/errors'
import { LedgerListPage } from './LedgerListPage'

const listLedgerEntries = vi.fn()
const getPeriodTotals = vi.fn()

vi.mock('../api/ledgerApi', () => ({
  listLedgerEntries: (...args: unknown[]) => listLedgerEntries(...args),
  getPeriodTotals: (...args: unknown[]) => getPeriodTotals(...args),
}))

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <LedgerListPage />
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

describe('LedgerListPage', () => {
  beforeEach(() => {
    listLedgerEntries.mockReset()
    getPeriodTotals.mockReset()
    getPeriodTotals.mockResolvedValue({
      from: '2024-06-01',
      to: '2024-06-30',
      total_income: '200.00',
      total_expenses: '50.00',
      net: '150.00',
    })
  })

  it('renders ledger entries and period totals from the API', async () => {
    listLedgerEntries.mockResolvedValue({
      items: [
        {
          id: '1',
          entry_type: 'income',
          occurred_at: '2024-06-15',
          category: 'product_sale',
          amount: '100.00',
          unit: null,
          total_price: '100.00',
          note: null,
          is_archived: false,
          created_at: '2024-06-15T00:00:00Z',
          updated_at: '2024-06-15T00:00:00Z',
        },
      ],
      meta: { total: 1, limit: 100, offset: 0 },
    })

    renderPage()

    await waitFor(() => {
      expect(screen.getByText(/Income · 100.00/)).toBeInTheDocument()
    })
    expect(screen.getByText(/2024-06-15 · Product sale/)).toBeInTheDocument()
    expect(screen.getByText('200.00')).toBeInTheDocument()
    expect(screen.getByText('50.00')).toBeInTheDocument()
    expect(screen.getByText('150.00')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /Add entry/i })).toHaveAttribute(
      'href',
      '/ledger/new',
    )
  })

  it('shows the API message when listing fails', async () => {
    listLedgerEntries.mockRejectedValue(
      new ApiError(401, {
        code: 'UNAUTHORIZED',
        message: 'Authentication required.',
      }),
    )

    renderPage()

    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent('Authentication required.')
    })
  })
})
