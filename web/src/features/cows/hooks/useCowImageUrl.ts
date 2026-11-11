import { useEffect, useState } from 'react'
import { apiUrl } from '../../../shared/api/client'
import { getAccessToken } from '../../../shared/auth/session'

export function useCowImageUrl(cowId: string | undefined, imageUrl: string | null | undefined) {
  const [url, setUrl] = useState<string | null>(null)

  useEffect(() => {
    let objectUrl: string | null = null
    let cancelled = false

    async function load() {
      if (!cowId || !imageUrl) {
        setUrl(null)
        return
      }
      const token = getAccessToken()
      if (!token) {
        setUrl(null)
        return
      }
      const response = await fetch(apiUrl(`/api/v1/cows/${cowId}/image`), {
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
  }, [cowId, imageUrl])

  return url
}
