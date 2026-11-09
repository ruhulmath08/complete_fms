import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { CowForm } from './CowForm'

describe('CowForm', () => {
  it('shows purchase fields only when acquired by purchase', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()

    render(<CowForm submitLabel="Save" onSubmit={onSubmit} />)

    expect(screen.queryByLabelText('Purchase date')).not.toBeInTheDocument()
    expect(screen.queryByLabelText('Purchase price')).not.toBeInTheDocument()

    await user.selectOptions(screen.getByLabelText('Acquired by'), 'purchased')

    expect(screen.getByLabelText('Purchase date')).toBeInTheDocument()
    expect(screen.getByLabelText('Purchase price')).toBeInTheDocument()
  })

  it('submits born-on-farm payload without purchase fields', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()

    render(<CowForm submitLabel="Save" onSubmit={onSubmit} />)

    await user.type(screen.getByLabelText('Tag number'), 'B-1')
    await user.click(screen.getByRole('button', { name: 'Save' }))

    expect(onSubmit).toHaveBeenCalledWith(
      expect.objectContaining({
        tag_number: 'B-1',
        acquired_by: 'born_on_farm',
        purchase_date: null,
        purchase_price: null,
      }),
    )
  })
})
