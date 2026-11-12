import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { listCropCycles, listCropNames } from "../api/cropsApi";
import { DEFAULT_PAGE_SIZE } from "../../../shared/constants/pagination";
import { getErrorMessage } from "../../../shared/api/errors";
import { EmptyState } from "../../../shared/ui/EmptyState";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { PaginationControls } from "../../../shared/ui/PaginationControls";

export function CropCyclesListPage() {
  const [includeArchived, setIncludeArchived] = useState(false);
  const [offset, setOffset] = useState(0);
  const cyclesQuery = useQuery({
    queryKey: ["crop-cycles", { includeArchived, offset }],
    queryFn: () =>
      listCropCycles({
        include_archived: includeArchived,
        limit: DEFAULT_PAGE_SIZE,
        offset,
      }),
  });
  const namesQuery = useQuery({
    queryKey: ["crop-names", { includeArchived: true }],
    queryFn: () => listCropNames({ include_archived: true, limit: 100 }),
  });

  const nameById = useMemo(() => {
    const map = new Map<string, string>();
    for (const name of namesQuery.data?.items ?? []) {
      map.set(name.id, name.name);
    }
    return map;
  }, [namesQuery.data]);

  function onIncludeArchivedChange(checked: boolean) {
    setIncludeArchived(checked);
    setOffset(0);
  }

  const items = cyclesQuery.data?.items ?? [];
  const total = cyclesQuery.data?.meta.total ?? 0;

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <div className="page-toolbar">
        <div>
          <h1>Crops</h1>
          <p className="lede">
            Planting cycles, expenses, harvests, and results.
          </p>
        </div>
        <div className="toolbar-actions">
          <Link className="btn btn-ghost" to="/crops/names">
            Crop names
          </Link>
          <Link className="btn btn-primary" to="/crops/cycles/new">
            Add cycle
          </Link>
        </div>
      </div>

      <label className="checkbox-row">
        <input
          type="checkbox"
          checked={includeArchived}
          onChange={(e) => onIncludeArchivedChange(e.target.checked)}
        />
        Include archived
      </label>

      {cyclesQuery.isError ? (
        <ErrorBanner message={getErrorMessage(cyclesQuery.error)} />
      ) : null}
      {cyclesQuery.isLoading ? (
        <LoadingState message="Loading crop cycles…" />
      ) : null}

      {!cyclesQuery.isLoading && !cyclesQuery.isError && items.length === 0 ? (
        <EmptyState
          message="No crop cycles yet. Add a crop name, then start your first cycle."
          action={
            <Link className="btn btn-primary" to="/crops/cycles/new">
              Add cycle
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
                  <th scope="col">Crop</th>
                  <th scope="col">Plot</th>
                  <th scope="col">Planted</th>
                  <th scope="col">Location</th>
                  <th scope="col">Status</th>
                </tr>
              </thead>
              <tbody>
                {items.map((cycle) => (
                  <tr key={cycle.id}>
                    <td>
                      <Link to={`/crops/cycles/${cycle.id}`}>
                        {nameById.get(cycle.crop_name_id) ?? "Crop"}
                      </Link>
                    </td>
                    <td>{cycle.plot_name ?? "—"}</td>
                    <td>{cycle.planted_at}</td>
                    <td>{cycle.location ?? "—"}</td>
                    <td>{cycle.is_archived ? "Archived" : "Active"}</td>
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
            label="Crop cycles"
          />
        </>
      ) : null}
    </div>
  );
}
