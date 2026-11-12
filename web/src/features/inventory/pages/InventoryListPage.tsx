import { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { listInventoryItems } from "../api/inventoryApi";
import { INVENTORY_CATEGORIES } from "../types";
import { DEFAULT_PAGE_SIZE } from "../../../shared/constants/pagination";
import { getErrorMessage } from "../../../shared/api/errors";
import { EmptyState } from "../../../shared/ui/EmptyState";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { PaginationControls } from "../../../shared/ui/PaginationControls";

function categoryLabel(category: string): string {
  return (
    INVENTORY_CATEGORIES.find((item) => item.value === category)?.label ??
    category
  );
}

export function InventoryListPage() {
  const [includeArchived, setIncludeArchived] = useState(false);
  const [offset, setOffset] = useState(0);
  const query = useQuery({
    queryKey: ["inventory-items", { includeArchived, offset }],
    queryFn: () =>
      listInventoryItems({
        include_archived: includeArchived,
        limit: DEFAULT_PAGE_SIZE,
        offset,
      }),
  });

  function onIncludeArchivedChange(checked: boolean) {
    setIncludeArchived(checked);
    setOffset(0);
  }

  const items = query.data?.items ?? [];
  const total = query.data?.meta.total ?? 0;

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <div className="page-toolbar">
        <div>
          <h1>Inventory</h1>
          <p className="lede">
            Supplies on hand with stock add and use updates.
          </p>
        </div>
        <Link className="btn btn-primary" to="/inventory/new">
          Add item
        </Link>
      </div>

      <label className="checkbox-row">
        <input
          type="checkbox"
          checked={includeArchived}
          onChange={(e) => onIncludeArchivedChange(e.target.checked)}
        />
        Include archived
      </label>

      {query.isError ? (
        <ErrorBanner message={getErrorMessage(query.error)} />
      ) : null}
      {query.isLoading ? <LoadingState message="Loading inventory…" /> : null}

      {!query.isLoading && !query.isError && items.length === 0 ? (
        <EmptyState
          message="No inventory items yet. Add feed, fertilizer, or supplies."
          action={
            <Link className="btn btn-primary" to="/inventory/new">
              Add item
            </Link>
          }
        />
      ) : null}

      {items.length > 0 ? (
        <>
          <div className="table-responsive">
            <table className="table table-striped table-bordered">
              <thead>
                <tr>
                  <th scope="col">Name</th>
                  <th scope="col">Category</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Total</th>
                  <th scope="col">Status</th>
                </tr>
              </thead>
              <tbody>
                {items.map((item) => (
                  <tr key={item.id}>
                    <td>
                      <Link to={`/inventory/${item.id}`}>{item.name}</Link>
                    </td>
                    <td>{categoryLabel(item.category)}</td>
                    <td>
                      {item.quantity} {item.unit}
                    </td>
                    <td>{item.total_price}</td>
                    <td>{item.is_archived ? "Archived" : "Active"}</td>
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
            label="Inventory"
          />
        </>
      ) : null}
    </div>
  );
}
