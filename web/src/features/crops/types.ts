export type ExpenseCategory =
  | "labour"
  | "fertilizers"
  | "pesticides_and_chemicals"
  | "seeds"
  | "irrigation"
  | "equipment"
  | "other";

export const EXPENSE_CATEGORIES: { value: ExpenseCategory; label: string }[] = [
  { value: "labour", label: "Labour" },
  { value: "fertilizers", label: "Fertilizers" },
  { value: "pesticides_and_chemicals", label: "Pesticides and chemicals" },
  { value: "seeds", label: "Seeds" },
  { value: "irrigation", label: "Irrigation" },
  { value: "equipment", label: "Equipment" },
  { value: "other", label: "Other" },
];

export type CropName = {
  id: string;
  name: string;
  notes: string | null;
  is_archived: boolean;
  created_at: string;
  updated_at: string;
};

export type CropCycle = {
  id: string;
  crop_name_id: string;
  plot_name: string | null;
  area: string | null;
  location: string | null;
  planted_at: string;
  expected_harvest_at: string | null;
  notes: string | null;
  is_archived: boolean;
  created_at: string;
  updated_at: string;
};

export type CropExpense = {
  id: string;
  crop_cycle_id: string;
  spent_at: string;
  category: ExpenseCategory;
  amount: string;
  note: string | null;
  created_at: string;
};

export type Harvest = {
  id: string;
  crop_cycle_id: string;
  harvested_at: string;
  quantity: string;
  unit: string;
  sale_amount: string | null;
  note: string | null;
  created_at: string;
};

export type CycleSummary = {
  crop_cycle_id: string;
  total_expenses: string;
  total_sale_income: string;
  result: string;
};

export type PageMeta = {
  total: number;
  limit: number;
  offset: number;
};

export type Page<T> = {
  items: T[];
  meta: PageMeta;
};

export type CropNameCreateInput = {
  name: string;
  notes?: string | null;
};

export type CropNameUpdateInput = Partial<CropNameCreateInput>;

export type CropCycleCreateInput = {
  crop_name_id: string;
  planted_at: string;
  plot_name?: string | null;
  area?: string | null;
  location?: string | null;
  expected_harvest_at?: string | null;
  notes?: string | null;
};

export type CropCycleUpdateInput = Partial<CropCycleCreateInput>;

export type ExpenseCreateInput = {
  spent_at: string;
  category: ExpenseCategory;
  amount: string;
  note?: string | null;
};

export type HarvestCreateInput = {
  harvested_at: string;
  quantity: string;
  unit: string;
  sale_amount?: string | null;
  note?: string | null;
};
