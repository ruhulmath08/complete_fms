import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { ApiError } from '../../../shared/api/errors'
import { CowsListPage } from './CowsListPage'

const listCows = vi.fn()

vi.mock('../api/cowsApi', () => ({
  listCows: (...args: unknown[]) => listCows(...args),
}))

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <CowsListPage />
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

describe('CowsListPage', () => {
  beforeEach(() => {
    listCows.mockReset()
  })

  it('renders cows from the API', async () => {
    listCows.mockResolvedValue({
      items: [
        {
          id: '1',
          tag_number: 'C-100',
          name: 'Bella',
          breed: null,
          date_of_birth: null,
          purpose: 'milk',
          gender: 'female',
          color: null,
          weight: null,
          age: null,
          acquired_by: 'born_on_farm',
          purchase_date: null,
          purchase_price: null,
          notes: null,
          is_archived: false,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z',
        },
      ],
      meta: { total: 1, limit: 100, offset: 0 },
    })

    renderPage()

    await waitFor(() => {
      expect(screen.getByText('C-100')).toBeInTheDocument()
    })
    expect(screen.getByText(/Bella/)).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /Add cow/i })).toHaveAttribute(
      'href',
      '/cows/new',
    )
  })

  it('shows the API message when listing fails', async () => {
    listCows.mockRejectedValue(
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
