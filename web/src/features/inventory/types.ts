export type InventoryCategory =
  | 'feed'
  | 'fertilizer'
  | 'pesticide'
  | 'seed'
  | 'medicine'
  | 'equipment'
  | 'fuel'
  | 'other'

export const INVENTORY_CATEGORIES: { value: InventoryCategory; label: string }[] = [
  { value: 'feed', label: 'Feed' },
  { value: 'fertilizer', label: 'Fertilizer' },
  { value: 'pesticide', label: 'Pesticide' },
  { value: 'seed', label: 'Seed' },
  { value: 'medicine', label: 'Medicine' },
  { value: 'equipment', label: 'Equipment' },
  { value: 'fuel', label: 'Fuel' },
  { value: 'other', label: 'Other' },
]

export type StockChangeType = 'add' | 'use'

export type InventoryItem = {
  id: string
  name: string
  category: InventoryCategory
  quantity: string
  unit: string
  price_per_unit: string
  total_price: string
  note: string | null
  is_archived: boolean
  created_at: string
  updated_at: string
}

export type StockUpdate = {
  id: string
  inventory_item_id: string
  occurred_at: string
  change_type: StockChangeType
  quantity_change: string
  reason: string | null
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

export type InventoryItemCreateInput = {
  name: string
  category: InventoryCategory
  quantity: string
  unit: string
  price_per_unit: string
  note?: string | null
}

export type InventoryItemUpdateInput = {
  name?: string
  category?: InventoryCategory
  unit?: string
  price_per_unit?: string
  note?: string | null
}

export type StockUpdateCreateInput = {
  occurred_at: string
  change_type: StockChangeType
  quantity_change: string
  reason?: string | null
}
