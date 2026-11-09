import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { CropCycleForm } from './CropCycleForm'
import type { CropName } from '../types'

const cropNames: CropName[] = [
  {
    id: 'name-1',
    name: 'Rice',
    notes: null,
    is_archived: false,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
  {
    id: 'name-2',
    name: 'Maize',
    notes: null,
    is_archived: false,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
]

describe('CropCycleForm', () => {
  it('submits cycle payload with selected crop name', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()

    render(
      <CropCycleForm
        cropNames={cropNames}
        submitLabel="Save"
        onSubmit={onSubmit}
      />,
    )

    await user.selectOptions(screen.getByLabelText('Crop'), 'name-2')
    await user.type(screen.getByLabelText('Planted at'), '2024-06-15')
    await user.type(screen.getByLabelText('Plot name'), 'East plot')
    await user.click(screen.getByRole('button', { name: 'Save' }))

    expect(onSubmit).toHaveBeenCalledWith(
      expect.objectContaining({
        crop_name_id: 'name-2',
        planted_at: '2024-06-15',
        plot_name: 'East plot',
        area: null,
        location: null,
        expected_harvest_at: null,
        notes: null,
      }),
    )
  })
})
