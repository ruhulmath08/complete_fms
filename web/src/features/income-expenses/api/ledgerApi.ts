import { apiRequest } from "../../../shared/api/client";
import type {
  LedgerEntry,
  LedgerEntryCreateInput,
  LedgerEntryUpdateInput,
  LedgerSeries,
  Page,
  PeriodTotals,
} from "../types";

export async function listLedgerEntries(params?: {
  limit?: number;
  offset?: number;
  include_archived?: boolean;
  from?: string;
  to?: string;
}): Promise<Page<LedgerEntry>> {
  const search = new URLSearchParams();
  if (params?.limit != null) search.set("limit", String(params.limit));
  if (params?.offset != null) search.set("offset", String(params.offset));
  if (params?.include_archived) search.set("include_archived", "true");
  if (params?.from) search.set("from", params.from);
  if (params?.to) search.set("to", params.to);
  const qs = search.toString();
  return apiRequest<Page<LedgerEntry>>(
    `/api/v1/ledger-entries${qs ? `?${qs}` : ""}`,
  );
}

export async function getLedgerEntry(entryId: string): Promise<LedgerEntry> {
  return apiRequest<LedgerEntry>(`/api/v1/ledger-entries/${entryId}`);
}

export async function createLedgerEntry(
  input: LedgerEntryCreateInput,
): Promise<LedgerEntry> {
  return apiRequest<LedgerEntry>("/api/v1/ledger-entries", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateLedgerEntry(
  entryId: string,
  input: LedgerEntryUpdateInput,
): Promise<LedgerEntry> {
  return apiRequest<LedgerEntry>(`/api/v1/ledger-entries/${entryId}`, {
    method: "PATCH",
    body: JSON.stringify(input),
  });
}

export async function archiveLedgerEntry(
  entryId: string,
): Promise<LedgerEntry> {
  return apiRequest<LedgerEntry>(`/api/v1/ledger-entries/${entryId}/archive`, {
    method: "POST",
  });
}

export async function getPeriodTotals(params: {
  from: string;
  to: string;
}): Promise<PeriodTotals> {
  const search = new URLSearchParams({
    from: params.from,
    to: params.to,
  });
  return apiRequest<PeriodTotals>(`/api/v1/ledger-entries/totals?${search}`);
}

export async function getLedgerSeries(params: {
  from: string;
  to: string;
  grain: string;
}): Promise<LedgerSeries> {
  const search = new URLSearchParams({
    from: params.from,
    to: params.to,
    grain: params.grain,
  });
  return apiRequest<LedgerSeries>(`/api/v1/ledger-entries/series?${search}`);
}
