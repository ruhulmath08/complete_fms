import { apiRequest } from "../../../shared/api/client";
import type { DashboardAggregates } from "../types";

export async function getDashboardAggregates(params: {
  from: string;
  to: string;
  grain: string;
}): Promise<DashboardAggregates> {
  const search = new URLSearchParams({
    from: params.from,
    to: params.to,
    grain: params.grain,
  });
  return apiRequest<DashboardAggregates>(
    `/api/v1/dashboard/aggregates?${search}`,
  );
}
