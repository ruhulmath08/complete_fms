import { apiRequest } from "../../../shared/api/client";
import type {
  EggCreateInput,
  EggProduction,
  EggUpdateInput,
  FeedingCreateInput,
  FeedingUpdateInput,
  Page,
  PoultryFeeding,
  PoultryGroup,
  PoultryGroupCreateInput,
  PoultryGroupUpdateInput,
} from "../types";

export async function listPoultryGroups(params?: {
  limit?: number;
  offset?: number;
  include_archived?: boolean;
}): Promise<Page<PoultryGroup>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  if (params?.include_archived) search.set("include_archived", "true");
  const qs = search.toString();
  return apiRequest<Page<PoultryGroup>>(
    `/api/v1/poultry-groups${qs ? `?${qs}` : ""}`,
  );
}

export async function getPoultryGroup(groupId: string): Promise<PoultryGroup> {
  return apiRequest<PoultryGroup>(`/api/v1/poultry-groups/${groupId}`);
}

export async function createPoultryGroup(
  input: PoultryGroupCreateInput,
): Promise<PoultryGroup> {
  return apiRequest<PoultryGroup>("/api/v1/poultry-groups", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updatePoultryGroup(
  groupId: string,
  input: PoultryGroupUpdateInput,
): Promise<PoultryGroup> {
  return apiRequest<PoultryGroup>(`/api/v1/poultry-groups/${groupId}`, {
    method: "PATCH",
    body: JSON.stringify(input),
  });
}

export async function archivePoultryGroup(
  groupId: string,
): Promise<PoultryGroup> {
  return apiRequest<PoultryGroup>(`/api/v1/poultry-groups/${groupId}/archive`, {
    method: "POST",
  });
}

export async function listEggProductions(
  groupId: string,
  params?: { limit?: number; offset?: number },
): Promise<Page<EggProduction>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  const qs = search.toString();
  return apiRequest<Page<EggProduction>>(
    `/api/v1/poultry-groups/${groupId}/egg-productions${qs ? `?${qs}` : ""}`,
  );
}

export async function addEggProduction(
  groupId: string,
  input: EggCreateInput,
): Promise<EggProduction> {
  return apiRequest<EggProduction>(
    `/api/v1/poultry-groups/${groupId}/egg-productions`,
    {
      method: "POST",
      body: JSON.stringify(input),
    },
  );
}

export async function updateEggProduction(
  groupId: string,
  eggId: string,
  input: EggUpdateInput,
): Promise<EggProduction> {
  return apiRequest<EggProduction>(
    `/api/v1/poultry-groups/${groupId}/egg-productions/${eggId}`,
    {
      method: "PATCH",
      body: JSON.stringify(input),
    },
  );
}

export async function deleteEggProduction(
  groupId: string,
  eggId: string,
): Promise<void> {
  await apiRequest<void>(
    `/api/v1/poultry-groups/${groupId}/egg-productions/${eggId}`,
    {
      method: "DELETE",
    },
  );
}

export async function listPoultryFeedings(
  groupId: string,
  params?: { limit?: number; offset?: number },
): Promise<Page<PoultryFeeding>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  const qs = search.toString();
  return apiRequest<Page<PoultryFeeding>>(
    `/api/v1/poultry-groups/${groupId}/feedings${qs ? `?${qs}` : ""}`,
  );
}

export async function addPoultryFeeding(
  groupId: string,
  input: FeedingCreateInput,
): Promise<PoultryFeeding> {
  return apiRequest<PoultryFeeding>(
    `/api/v1/poultry-groups/${groupId}/feedings`,
    {
      method: "POST",
      body: JSON.stringify(input),
    },
  );
}

export async function updatePoultryFeeding(
  groupId: string,
  feedingId: string,
  input: FeedingUpdateInput,
): Promise<PoultryFeeding> {
  return apiRequest<PoultryFeeding>(
    `/api/v1/poultry-groups/${groupId}/feedings/${feedingId}`,
    {
      method: "PATCH",
      body: JSON.stringify(input),
    },
  );
}

export async function deletePoultryFeeding(
  groupId: string,
  feedingId: string,
): Promise<void> {
  await apiRequest<void>(
    `/api/v1/poultry-groups/${groupId}/feedings/${feedingId}`,
    {
      method: "DELETE",
    },
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
