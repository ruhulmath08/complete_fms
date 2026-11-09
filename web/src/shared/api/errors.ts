import type { ApiErrorBody } from './types'

export class ApiError extends Error {
  code: string
  details?: Record<string, unknown>
  status: number

  constructor(status: number, body: ApiErrorBody) {
    super(body.message)
    this.name = 'ApiError'
    this.status = status
    this.code = body.code
    this.details = body.details
  }
}

export function getErrorMessage(error: unknown, fallback = 'Something went wrong.') {
  if (error instanceof ApiError) return error.message
  if (error instanceof Error) return error.message
  return fallback
}
