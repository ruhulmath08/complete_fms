import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { ApiError } from '../../../shared/api/errors'
import { CowCreatePage } from './CowCreatePage'

const createCow = vi.fn()

vi.mock('../api/cowsApi', () => ({
  createCow: (...args: unknown[]) => createCow(...args),
}))

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <CowCreatePage />
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

describe('CowCreatePage', () => {
  beforeEach(() => {
    createCow.mockReset()
  })

  it('shows the API message when tag already exists', async () => {
    const user = userEvent.setup()
    createCow.mockRejectedValue(
      new ApiError(409, {
        code: 'TAG_ALREADY_EXISTS',
        message: 'An active cow with this tag number already exists.',
      }),
    )

    renderPage()

    await user.type(screen.getByLabelText('Tag number'), 'C-100')
    await user.click(screen.getByRole('button', { name: 'Create cow' }))

    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent(
        'An active cow with this tag number already exists.',
      )
    })
    expect(createCow).toHaveBeenCalled()
  })
})
