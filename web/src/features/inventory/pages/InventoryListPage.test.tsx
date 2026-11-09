import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { ApiError } from '../../../shared/api/errors'
import { InventoryListPage } from './InventoryListPage'

const listInventoryItems = vi.fn()

vi.mock('../api/inventoryApi', () => ({
  listInventoryItems: (...args: unknown[]) => listInventoryItems(...args),
}))

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <InventoryListPage />
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

describe('InventoryListPage', () => {
  beforeEach(() => {
    listInventoryItems.mockReset()
  })

  it('renders inventory items from the API', async () => {
    listInventoryItems.mockResolvedValue({
      items: [
        {
          id: '1',
          name: 'Layer feed',
          category: 'feed',
          quantity: '100.000',
          unit: 'kg',
          price_per_unit: '50.00',
          total_price: '5000.00',
          note: null,
          is_archived: false,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z',
        },
      ],
      meta: { total: 1, limit: 100, offset: 0 },
    })

    renderPage()

    await waitFor(() => {
      expect(screen.getByText('Layer feed')).toBeInTheDocument()
    })
    expect(screen.getByText(/Feed · 100.000 kg · total 5000.00/)).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /Add item/i })).toHaveAttribute(
      'href',
      '/inventory/new',
    )
  })

  it('shows the API message when listing fails', async () => {
    listInventoryItems.mockRejectedValue(
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
