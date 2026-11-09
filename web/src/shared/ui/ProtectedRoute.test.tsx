import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'
import { ProtectedRoute } from './ProtectedRoute'

vi.mock('../auth/useAuth', () => ({
  useAuth: () => ({
    isSignedIn: false,
    signIn: vi.fn(),
    signOut: vi.fn(),
    markSignedOut: vi.fn(),
  }),
}))

describe('ProtectedRoute', () => {
  it('redirects unsigned users to sign-in', () => {
    render(
      <MemoryRouter initialEntries={['/profile']}>
        <Routes>
          <Route path="/signin" element={<div>Sign in gate</div>} />
          <Route element={<ProtectedRoute />}>
            <Route path="/profile" element={<div>Private profile</div>} />
          </Route>
        </Routes>
      </MemoryRouter>,
    )

    expect(screen.getByText('Sign in gate')).toBeInTheDocument()
    expect(screen.queryByText('Private profile')).not.toBeInTheDocument()
  })
})
