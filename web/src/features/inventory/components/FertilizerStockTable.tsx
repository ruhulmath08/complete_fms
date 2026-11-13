import { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { listInventoryStockUpdates } from "../api/inventoryApi";
import { DEFAULT_PAGE_SIZE } from "../../../shared/constants/pagination";
import { getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { PaginationControls } from "../../../shared/ui/PaginationControls";

export function FertilizerStockTable() {
  const [offset, setOffset] = useState(0);
  const query = useQuery({
    queryKey: ["inventory-stock-updates", { category: "fertilizer", offset }],
    queryFn: () =>
      listInventoryStockUpdates({
        category: "fertilizer",
        limit: DEFAULT_PAGE_SIZE,
        offset,
      }),
  });

  const items = query.data?.items ?? [];
  const total = query.data?.meta.total ?? 0;

  return (
    <section className="detail-section">
      <h2>Fertilizer stock history</h2>
      {query.isError ? (
        <ErrorBanner message={getErrorMessage(query.error)} />
      ) : null}
      {query.isLoading ? (
        <LoadingState message="Loading fertilizer stock history…" />
      ) : null}
      {!query.isLoading && !query.isError && items.length === 0 ? (
        <p className="muted">No fertilizer stock updates yet.</p>
      ) : null}
      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">No.</th>
                  <th scope="col">Date</th>
                  <th scope="col">Item</th>
                  <th scope="col">Change</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Reason</th>
                </tr>
              </thead>
              <tbody>
                {items.map((row, index) => (
                  <tr key={row.id}>
                    <td>{offset + index + 1}</td>
                    <td>{row.occurred_at}</td>
                    <td>
                      <Link to={`/inventory/${row.inventory_item_id}`}>
                        {row.item_name}
                      </Link>
                    </td>
                    <td>{row.change_type === "add" ? "Add" : "Use"}</td>
                    <td>
                      {row.quantity_change} {row.item_unit}
                    </td>
                    <td>{row.reason ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationControls
            total={total}
            limit={DEFAULT_PAGE_SIZE}
            offset={offset}
            onOffsetChange={setOffset}
            label="Fertilizer stock history"
          />
        </>
      ) : null}
    </section>
  );
}
