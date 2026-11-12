import { apiRequest } from "../../../shared/api/client";
import type {
  InventoryItem,
  InventoryItemCreateInput,
  InventoryItemUpdateInput,
  Page,
  StockUpdate,
  StockUpdateCreateInput,
} from "../types";

export async function listInventoryItems(params?: {
  limit?: number;
  offset?: number;
  include_archived?: boolean;
}): Promise<Page<InventoryItem>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  if (params?.include_archived) search.set("include_archived", "true");
  const qs = search.toString();
  return apiRequest<Page<InventoryItem>>(
    `/api/v1/inventory-items${qs ? `?${qs}` : ""}`,
  );
}

export async function getInventoryItem(itemId: string): Promise<InventoryItem> {
  return apiRequest<InventoryItem>(`/api/v1/inventory-items/${itemId}`);
}

export async function createInventoryItem(
  input: InventoryItemCreateInput,
): Promise<InventoryItem> {
  return apiRequest<InventoryItem>("/api/v1/inventory-items", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateInventoryItem(
  itemId: string,
  input: InventoryItemUpdateInput,
): Promise<InventoryItem> {
  return apiRequest<InventoryItem>(`/api/v1/inventory-items/${itemId}`, {
    method: "PATCH",
    body: JSON.stringify(input),
  });
}

export async function archiveInventoryItem(
  itemId: string,
): Promise<InventoryItem> {
  return apiRequest<InventoryItem>(
    `/api/v1/inventory-items/${itemId}/archive`,
    {
      method: "POST",
    },
  );
}

export async function listStockUpdates(
  itemId: string,
  params?: { limit?: number; offset?: number },
): Promise<Page<StockUpdate>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  const qs = search.toString();
  return apiRequest<Page<StockUpdate>>(
    `/api/v1/inventory-items/${itemId}/stock-updates${qs ? `?${qs}` : ""}`,
  );
}

export async function addStockUpdate(
  itemId: string,
  input: StockUpdateCreateInput,
): Promise<StockUpdate> {
  return apiRequest<StockUpdate>(
    `/api/v1/inventory-items/${itemId}/stock-updates`,
    {
      method: "POST",
      body: JSON.stringify(input),
    },
  );
}
