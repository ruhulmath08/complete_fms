export type CowPurpose = 'milk' | 'meat' | 'both'
export type CowGender = 'female' | 'male' | 'unknown'
export type AcquisitionSource = 'purchased' | 'born_on_farm'

export type Cow = {
  id: string
  tag_number: string
  name: string | null
  breed: string | null
  date_of_birth: string | null
  purpose: CowPurpose
  gender: CowGender
  color: string | null
  weight: string | null
  age: number | null
  acquired_by: AcquisitionSource
  purchase_date: string | null
  purchase_price: string | null
  notes: string | null
  is_archived: boolean
  created_at: string
  updated_at: string
}

export type MilkProduction = {
  id: string
  cow_id: string
  produced_at: string
  quantity: string
  unit: string
  price_per_unit: string
  note: string | null
  created_at: string
}

export type CowFeeding = {
  id: string
  cow_id: string
  fed_at: string
  feed_name: string
  quantity: string
  unit: string
  note: string | null
  created_at: string
}

export type PageMeta = {
  total: number
  limit: number
  offset: number
}

export type Page<T> = {
  items: T[]
  meta: PageMeta
}

export type CowCreateInput = {
  tag_number: string
  purpose: CowPurpose
  gender: CowGender
  acquired_by: AcquisitionSource
  name?: string | null
  breed?: string | null
  date_of_birth?: string | null
  color?: string | null
  weight?: string | null
  age?: number | null
  purchase_date?: string | null
  purchase_price?: string | null
  notes?: string | null
}

export type CowUpdateInput = Partial<CowCreateInput>

export type MilkCreateInput = {
  produced_at: string
  quantity: string
  unit: string
  price_per_unit: string
  note?: string | null
}

export type FeedingCreateInput = {
  fed_at: string
  feed_name: string
  quantity: string
  unit: string
  note?: string | null
}
