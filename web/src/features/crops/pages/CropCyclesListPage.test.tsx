import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { ApiError } from '../../../shared/api/errors'
import { CropCyclesListPage } from './CropCyclesListPage'

const listCropCycles = vi.fn()
const listCropNames = vi.fn()

vi.mock('../api/cropsApi', () => ({
  listCropCycles: (...args: unknown[]) => listCropCycles(...args),
  listCropNames: (...args: unknown[]) => listCropNames(...args),
}))

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <CropCyclesListPage />
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

describe('CropCyclesListPage', () => {
  beforeEach(() => {
    listCropCycles.mockReset()
    listCropNames.mockReset()
    listCropNames.mockResolvedValue({
      items: [
        {
          id: 'name-1',
          name: 'Rice',
          notes: null,
          is_archived: false,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z',
        },
      ],
      meta: { total: 1, limit: 100, offset: 0 },
    })
  })

  it('renders crop cycles from the API', async () => {
    listCropCycles.mockResolvedValue({
      items: [
        {
          id: 'cycle-1',
          crop_name_id: 'name-1',
          plot_name: 'North field',
          area: '2.5',
          location: 'Block A',
          planted_at: '2024-06-01',
          expected_harvest_at: null,
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
      expect(screen.getByText(/Rice · North field/)).toBeInTheDocument()
    })
    expect(screen.getByText(/Planted 2024-06-01 · Block A/)).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /Add cycle/i })).toHaveAttribute(
      'href',
      '/crops/cycles/new',
    )
  })

  it('shows the API message when listing fails', async () => {
    listCropCycles.mockRejectedValue(
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
