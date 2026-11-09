import { describe, expect, it } from 'vitest'
import { ApiError, getErrorMessage } from './errors'

describe('ApiError helpers', () => {
  it('exposes API message and code for UI branching', () => {
    const error = new ApiError(401, {
      code: 'INVALID_CREDENTIALS',
      message: 'Email or password is incorrect.',
    })
    expect(error.code).toBe('INVALID_CREDENTIALS')
    expect(getErrorMessage(error)).toBe('Email or password is incorrect.')
  })

  it('falls back for unknown errors', () => {
    expect(getErrorMessage(new Error('boom'))).toBe('boom')
    expect(getErrorMessage('nope')).toBe('Something went wrong.')
  })
})
