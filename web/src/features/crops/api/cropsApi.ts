import { apiRequest } from "../../../shared/api/client";
import type {
  CropCycle,
  CropCycleCreateInput,
  CropCycleUpdateInput,
  CropExpense,
  CropName,
  CropNameCreateInput,
  CropNameUpdateInput,
  CycleSummary,
  ExpenseCreateInput,
  ExpenseUpdateInput,
  Harvest,
  HarvestCreateInput,
  HarvestUpdateInput,
  Page,
} from "../types";

export async function listCropNames(params?: {
  limit?: number;
  offset?: number;
  include_archived?: boolean;
}): Promise<Page<CropName>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  if (params?.include_archived) search.set("include_archived", "true");
  const qs = search.toString();
  return apiRequest<Page<CropName>>(`/api/v1/crop-names${qs ? `?${qs}` : ""}`);
}

export async function getCropName(cropNameId: string): Promise<CropName> {
  return apiRequest<CropName>(`/api/v1/crop-names/${cropNameId}`);
}

export async function createCropName(
  input: CropNameCreateInput,
): Promise<CropName> {
  return apiRequest<CropName>("/api/v1/crop-names", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateCropName(
  cropNameId: string,
  input: CropNameUpdateInput,
): Promise<CropName> {
  return apiRequest<CropName>(`/api/v1/crop-names/${cropNameId}`, {
    method: "PATCH",
    body: JSON.stringify(input),
  });
}

export async function archiveCropName(cropNameId: string): Promise<CropName> {
  return apiRequest<CropName>(`/api/v1/crop-names/${cropNameId}/archive`, {
    method: "POST",
  });
}

export async function listCropCycles(params?: {
  limit?: number;
  offset?: number;
  include_archived?: boolean;
}): Promise<Page<CropCycle>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  if (params?.include_archived) search.set("include_archived", "true");
  const qs = search.toString();
  return apiRequest<Page<CropCycle>>(
    `/api/v1/crop-cycles${qs ? `?${qs}` : ""}`,
  );
}

export async function getCropCycle(cycleId: string): Promise<CropCycle> {
  return apiRequest<CropCycle>(`/api/v1/crop-cycles/${cycleId}`);
}

export async function createCropCycle(
  input: CropCycleCreateInput,
): Promise<CropCycle> {
  return apiRequest<CropCycle>("/api/v1/crop-cycles", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateCropCycle(
  cycleId: string,
  input: CropCycleUpdateInput,
): Promise<CropCycle> {
  return apiRequest<CropCycle>(`/api/v1/crop-cycles/${cycleId}`, {
    method: "PATCH",
    body: JSON.stringify(input),
  });
}

export async function archiveCropCycle(cycleId: string): Promise<CropCycle> {
  return apiRequest<CropCycle>(`/api/v1/crop-cycles/${cycleId}/archive`, {
    method: "POST",
  });
}

export async function getCropCycleSummary(
  cycleId: string,
): Promise<CycleSummary> {
  return apiRequest<CycleSummary>(`/api/v1/crop-cycles/${cycleId}/summary`);
}

export async function listCropExpenses(
  cycleId: string,
  params?: { limit?: number; offset?: number },
): Promise<Page<CropExpense>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  const qs = search.toString();
  return apiRequest<Page<CropExpense>>(
    `/api/v1/crop-cycles/${cycleId}/expenses${qs ? `?${qs}` : ""}`,
  );
}

export async function addCropExpense(
  cycleId: string,
  input: ExpenseCreateInput,
): Promise<CropExpense> {
  return apiRequest<CropExpense>(`/api/v1/crop-cycles/${cycleId}/expenses`, {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateCropExpense(
  cycleId: string,
  expenseId: string,
  input: ExpenseUpdateInput,
): Promise<CropExpense> {
  return apiRequest<CropExpense>(
    `/api/v1/crop-cycles/${cycleId}/expenses/${expenseId}`,
    {
      method: "PATCH",
      body: JSON.stringify(input),
    },
  );
}

export async function deleteCropExpense(
  cycleId: string,
  expenseId: string,
): Promise<void> {
  await apiRequest<void>(
    `/api/v1/crop-cycles/${cycleId}/expenses/${expenseId}`,
    { method: "DELETE" },
  );
}

export async function listHarvests(
  cycleId: string,
  params?: { limit?: number; offset?: number },
): Promise<Page<Harvest>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  const qs = search.toString();
  return apiRequest<Page<Harvest>>(
    `/api/v1/crop-cycles/${cycleId}/harvests${qs ? `?${qs}` : ""}`,
  );
}

export async function addHarvest(
  cycleId: string,
  input: HarvestCreateInput,
): Promise<Harvest> {
  return apiRequest<Harvest>(`/api/v1/crop-cycles/${cycleId}/harvests`, {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateHarvest(
  cycleId: string,
  harvestId: string,
  input: HarvestUpdateInput,
): Promise<Harvest> {
  return apiRequest<Harvest>(
    `/api/v1/crop-cycles/${cycleId}/harvests/${harvestId}`,
    {
      method: "PATCH",
      body: JSON.stringify(input),
    },
  );
}

export async function deleteHarvest(
  cycleId: string,
  harvestId: string,
): Promise<void> {
  await apiRequest<void>(
    `/api/v1/crop-cycles/${cycleId}/harvests/${harvestId}`,
    { method: "DELETE" },
  );
}

export async function getSuggestedUnits(): Promise<string[]> {
  const data = await apiRequest<{ items: string[] }>(
    "/api/v1/config/suggested-units",
    {
      auth: false,
    },
  );
  return data.items;
}
