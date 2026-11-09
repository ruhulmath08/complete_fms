import { ApiError } from './errors'
import type { ApiErrorBody, TokenResponse } from './types'
import {
  clearTokens,
  getAccessToken,
  getRefreshToken,
  setTokens,
} from '../auth/session'

const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8000'

let refreshPromise: Promise<boolean> | null = null

async function parseError(response: Response): Promise<ApiError> {
  let body: ApiErrorBody = {
    code: 'HTTP_ERROR',
    message: 'Request failed.',
  }
  try {
    body = (await response.json()) as ApiErrorBody
  } catch {
    // keep defaults
  }
  return new ApiError(response.status, body)
}

async function refreshAccessToken(): Promise<boolean> {
  const refreshToken = getRefreshToken()
  if (!refreshToken) return false

  const response = await fetch(`${API_BASE}/api/v1/auth/refresh`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refresh_token: refreshToken }),
  })

  if (!response.ok) {
    clearTokens()
    return false
  }

  const data = (await response.json()) as TokenResponse
  setTokens(data.access_token, data.refresh_token)
  return true
}

async function ensureFreshSession(): Promise<boolean> {
  if (!refreshPromise) {
    refreshPromise = refreshAccessToken().finally(() => {
      refreshPromise = null
    })
  }
  return refreshPromise
}

type RequestOptions = {
  method?: string
  body?: BodyInit | null
  headers?: HeadersInit
  auth?: boolean
  formData?: boolean
}

export async function apiRequest<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const headers = new Headers(options.headers)
  if (!options.formData && options.body && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }

  const send = async (): Promise<Response> => {
    if (options.auth !== false) {
      const access = getAccessToken()
      if (access) headers.set('Authorization', `Bearer ${access}`)
      else headers.delete('Authorization')
    }
    return fetch(`${API_BASE}${path}`, {
      method: options.method ?? 'GET',
      headers,
      body: options.body,
    })
  }

  let response = await send()

  if (response.status === 401 && options.auth !== false) {
    const refreshed = await ensureFreshSession()
    if (refreshed) {
      response = await send()
    }
  }

  if (!response.ok) {
    throw await parseError(response)
  }

  if (response.status === 204) {
    return undefined as T
  }

  return (await response.json()) as T
}

export function apiUrl(path: string): string {
  return `${API_BASE}${path}`
}
