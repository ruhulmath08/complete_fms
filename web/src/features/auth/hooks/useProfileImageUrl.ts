import { useEffect, useState } from 'react'
import { apiUrl } from '../../../shared/api/client'
import { getAccessToken } from '../../../shared/auth/session'

export function useProfileImageUrl(updatedAt?: string) {
  const [url, setUrl] = useState<string | null>(null)

  useEffect(() => {
    let objectUrl: string | null = null
    let cancelled = false

    async function load() {
      const token = getAccessToken()
      if (!token) {
        setUrl(null)
        return
      }
      const response = await fetch(apiUrl('/api/v1/me/profile-image'), {
        headers: { Authorization: `Bearer ${token}` },
      })
      if (!response.ok || cancelled) return
      const blob = await response.blob()
      objectUrl = URL.createObjectURL(blob)
      if (!cancelled) setUrl(objectUrl)
    }

    void load()
    return () => {
      cancelled = true
      if (objectUrl) URL.revokeObjectURL(objectUrl)
    }
  }, [updatedAt])

  return url
}
