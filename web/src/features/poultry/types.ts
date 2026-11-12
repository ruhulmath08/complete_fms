export type PoultryType = "broiler" | "duck" | "layer" | "local";
export type AcquisitionSource = "purchased" | "born_on_farm";

export type PoultryGroup = {
  id: string;
  poultry_type: PoultryType;
  name: string;
  bird_count: number;
  date_acquired: string | null;
  acquired_by: AcquisitionSource;
  purchase_date: string | null;
  purchase_price: string | null;
  notes: string | null;
  is_archived: boolean;
  created_at: string;
  updated_at: string;
};

export type PoultryFeeding = {
  id: string;
  poultry_group_id: string;
  fed_at: string;
  feed_name: string;
  quantity: string;
  unit: string;
  note: string | null;
  created_at: string;
};

export type EggProduction = {
  id: string;
  poultry_group_id: string;
  produced_at: string;
  quantity: string;
  unit: string;
  price_per_unit: string;
  note: string | null;
  created_at: string;
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

export type PoultryGroupCreateInput = {
  poultry_type: PoultryType;
  name: string;
  bird_count: number;
  acquired_by: AcquisitionSource;
  date_acquired?: string | null;
  purchase_date?: string | null;
  purchase_price?: string | null;
  notes?: string | null;
};

export type PoultryGroupUpdateInput = Partial<PoultryGroupCreateInput>;

export type EggCreateInput = {
  produced_at: string;
  quantity: string;
  unit: string;
  price_per_unit: string;
  note?: string | null;
};

export type EggUpdateInput = Partial<EggCreateInput>;

export type FeedingCreateInput = {
  fed_at: string;
  feed_name: string;
  quantity: string;
  unit: string;
  note?: string | null;
};

export type FeedingUpdateInput = Partial<FeedingCreateInput>;
