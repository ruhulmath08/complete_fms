import { afterEach, describe, expect, it } from 'vitest'
import {
  clearTokens,
  getAccessToken,
  getRefreshToken,
  isSignedIn,
  setTokens,
} from './session'

describe('session storage', () => {
  afterEach(() => {
    clearTokens()
  })

  it('stores and reads access and refresh tokens', () => {
    expect(isSignedIn()).toBe(false)
    setTokens('access-1', 'refresh-1')
    expect(getAccessToken()).toBe('access-1')
    expect(getRefreshToken()).toBe('refresh-1')
    expect(isSignedIn()).toBe(true)
  })

  it('clears tokens on sign-out style cleanup', () => {
    setTokens('access-1', 'refresh-1')
    clearTokens()
    expect(getAccessToken()).toBeNull()
    expect(getRefreshToken()).toBeNull()
    expect(isSignedIn()).toBe(false)
  })
})
