import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { InventoryItemForm } from './InventoryItemForm'

describe('InventoryItemForm', () => {
  it('shows quantity only in create mode', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()

    const { rerender } = render(
      <InventoryItemForm mode="create" submitLabel="Save" onSubmit={onSubmit} />,
    )

    expect(screen.getByLabelText('Quantity')).toBeInTheDocument()

    rerender(
      <InventoryItemForm
        mode="edit"
        submitLabel="Save"
        onSubmit={onSubmit}
        initial={{
          id: '1',
          name: 'Feed',
          category: 'feed',
          quantity: '10',
          unit: 'kg',
          price_per_unit: '5',
          total_price: '50',
          note: null,
          is_archived: false,
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z',
        }}
      />,
    )

    expect(screen.queryByLabelText('Quantity')).not.toBeInTheDocument()

    await user.clear(screen.getByLabelText('Name'))
    await user.type(screen.getByLabelText('Name'), 'Updated feed')
    await user.click(screen.getByRole('button', { name: 'Save' }))

    expect(onSubmit).toHaveBeenCalledWith(
      expect.objectContaining({
        name: 'Updated feed',
        category: 'feed',
        unit: 'kg',
      }),
    )
    expect(onSubmit.mock.calls[0][0]).not.toHaveProperty('quantity')
  })
})
