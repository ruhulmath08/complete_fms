export type EntryType = 'income' | 'expense'

export const ENTRY_TYPES: { value: EntryType; label: string }[] = [
  { value: 'income', label: 'Income' },
  { value: 'expense', label: 'Expense' },
]

export type EntryCategory =
  | 'labour'
  | 'feed_or_supplies'
  | 'utilities'
  | 'transport'
  | 'equipment'
  | 'livestock_sale'
  | 'product_sale'
  | 'subsidy'
  | 'other'

export const ENTRY_CATEGORIES: { value: EntryCategory; label: string }[] = [
  { value: 'labour', label: 'Labour' },
  { value: 'feed_or_supplies', label: 'Feed or supplies' },
  { value: 'utilities', label: 'Utilities' },
  { value: 'transport', label: 'Transport' },
  { value: 'equipment', label: 'Equipment' },
  { value: 'livestock_sale', label: 'Livestock sale' },
  { value: 'product_sale', label: 'Product sale' },
  { value: 'subsidy', label: 'Subsidy' },
  { value: 'other', label: 'Other' },
]

export type LedgerEntry = {
  id: string
  entry_type: EntryType
  occurred_at: string
  category: EntryCategory
  amount: string
  unit: string | null
  total_price: string
  note: string | null
  is_archived: boolean
  created_at: string
  updated_at: string
}

export type PeriodTotals = {
  from: string
  to: string
  total_income: string
  total_expenses: string
  net: string
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

export type LedgerEntryCreateInput = {
  entry_type: EntryType
  occurred_at: string
  category: EntryCategory
  amount: string
  unit?: string | null
  note?: string | null
}

export type LedgerEntryUpdateInput = {
  entry_type?: EntryType
  occurred_at?: string
  category?: EntryCategory
  amount?: string
  unit?: string | null
  note?: string | null
}
