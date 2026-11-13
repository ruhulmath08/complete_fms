export const DASHBOARD_SERIES_KEYS = [
  "egg_production",
  "hen_headcount",
  "milk",
  "cow_production",
  "expenses_cost",
  "income",
] as const;

export type DashboardSeriesKey = (typeof DASHBOARD_SERIES_KEYS)[number];

export type DashboardSeriesPoint = {
  bucket_start: string;
  value: string;
};

export type DashboardAggregates = {
  from?: string;
  to: string;
  grain: string;
  timezone: string;
  series: Record<DashboardSeriesKey, DashboardSeriesPoint[]>;
};
