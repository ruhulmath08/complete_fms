import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { PoultryGroupForm } from './PoultryGroupForm'

describe('PoultryGroupForm', () => {
  it('shows purchase fields only when acquired by purchase', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()

    render(<PoultryGroupForm submitLabel="Save" onSubmit={onSubmit} />)

    expect(screen.queryByLabelText('Purchase date')).not.toBeInTheDocument()
    expect(screen.queryByLabelText('Purchase price')).not.toBeInTheDocument()

    await user.selectOptions(screen.getByLabelText('Acquired by'), 'purchased')

    expect(screen.getByLabelText('Purchase date')).toBeInTheDocument()
    expect(screen.getByLabelText('Purchase price')).toBeInTheDocument()
  })

  it('submits born-on-farm payload without purchase fields', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()

    render(<PoultryGroupForm submitLabel="Save" onSubmit={onSubmit} />)

    await user.clear(screen.getByLabelText('Group name'))
    await user.type(screen.getByLabelText('Group name'), 'House A')
    await user.clear(screen.getByLabelText('Bird count'))
    await user.type(screen.getByLabelText('Bird count'), '100')
    await user.click(screen.getByRole('button', { name: 'Save' }))

    expect(onSubmit).toHaveBeenCalledWith(
      expect.objectContaining({
        name: 'House A',
        bird_count: 100,
        acquired_by: 'born_on_farm',
        purchase_date: null,
        purchase_price: null,
      }),
    )
  })
})
