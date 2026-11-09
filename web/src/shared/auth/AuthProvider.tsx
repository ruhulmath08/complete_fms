import { useCallback, useMemo, useState, type ReactNode } from 'react'
import { signIn as apiSignIn, signOut as apiSignOut } from '../../features/auth/api/authApi'
import { AuthContext } from './auth-context'
import {
  clearTokens,
  getRefreshToken,
  isSignedIn as readSignedIn,
  setTokens,
} from './session'

export function AuthProvider({ children }: { children: ReactNode }) {
  const [isSignedIn, setIsSignedIn] = useState(() => readSignedIn())

  const signIn = useCallback(async (email: string, password: string) => {
    const tokens = await apiSignIn(email, password)
    setTokens(tokens.access_token, tokens.refresh_token)
    setIsSignedIn(true)
  }, [])

  const markSignedOut = useCallback(() => {
    clearTokens()
    setIsSignedIn(false)
  }, [])

  const signOut = useCallback(async () => {
    try {
      await apiSignOut(getRefreshToken())
    } catch {
      // Still clear local session if API sign-out fails.
    } finally {
      markSignedOut()
    }
  }, [markSignedOut])

  const value = useMemo(
    () => ({ isSignedIn, signIn, signOut, markSignedOut }),
    [isSignedIn, signIn, signOut, markSignedOut],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
