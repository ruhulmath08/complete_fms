import { apiRequest } from '../../../shared/api/client'
import type {
  Cow,
  CowCreateInput,
  CowFeeding,
  CowUpdateInput,
  FeedingCreateInput,
  MilkCreateInput,
  MilkProduction,
  Page,
} from '../types'

export async function listCows(params?: {
  limit?: number
  offset?: number
  include_archived?: boolean
}): Promise<Page<Cow>> {
  const search = new URLSearchParams()
  if (params?.limit != null) search.set('limit', String(params.limit))
  if (params?.offset != null) search.set('offset', String(params.offset))
  if (params?.include_archived) search.set('include_archived', 'true')
  const qs = search.toString()
  return apiRequest<Page<Cow>>(`/api/v1/cows${qs ? `?${qs}` : ''}`)
}

export async function getCow(cowId: string): Promise<Cow> {
  return apiRequest<Cow>(`/api/v1/cows/${cowId}`)
}

export async function createCow(input: CowCreateInput): Promise<Cow> {
  return apiRequest<Cow>('/api/v1/cows', {
    method: 'POST',
    body: JSON.stringify(input),
  })
}

export async function updateCow(cowId: string, input: CowUpdateInput): Promise<Cow> {
  return apiRequest<Cow>(`/api/v1/cows/${cowId}`, {
    method: 'PATCH',
    body: JSON.stringify(input),
  })
}

export async function archiveCow(cowId: string): Promise<Cow> {
  return apiRequest<Cow>(`/api/v1/cows/${cowId}/archive`, {
    method: 'POST',
  })
}

export async function listMilkProductions(
  cowId: string,
  params?: { limit?: number; offset?: number },
): Promise<Page<MilkProduction>> {
  const search = new URLSearchParams()
  if (params?.limit != null) search.set('limit', String(params.limit))
  if (params?.offset != null) search.set('offset', String(params.offset))
  const qs = search.toString()
  return apiRequest<Page<MilkProduction>>(
    `/api/v1/cows/${cowId}/milk-productions${qs ? `?${qs}` : ''}`,
  )
}

export async function addMilkProduction(
  cowId: string,
  input: MilkCreateInput,
): Promise<MilkProduction> {
  return apiRequest<MilkProduction>(`/api/v1/cows/${cowId}/milk-productions`, {
    method: 'POST',
    body: JSON.stringify(input),
  })
}

export async function listFeedings(
  cowId: string,
  params?: { limit?: number; offset?: number },
): Promise<Page<CowFeeding>> {
  const search = new URLSearchParams()
  if (params?.limit != null) search.set('limit', String(params.limit))
  if (params?.offset != null) search.set('offset', String(params.offset))
  const qs = search.toString()
  return apiRequest<Page<CowFeeding>>(
    `/api/v1/cows/${cowId}/feedings${qs ? `?${qs}` : ''}`,
  )
}

export async function addFeeding(
  cowId: string,
  input: FeedingCreateInput,
): Promise<CowFeeding> {
  return apiRequest<CowFeeding>(`/api/v1/cows/${cowId}/feedings`, {
    method: 'POST',
    body: JSON.stringify(input),
  })
}

export async function getSuggestedUnits(): Promise<string[]> {
  const data = await apiRequest<{ items: string[] }>('/api/v1/config/suggested-units', {
    auth: false,
  })
  return data.items
}
