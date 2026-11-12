import { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { listCropNames } from "../api/cropsApi";
import { DEFAULT_PAGE_SIZE } from "../../../shared/constants/pagination";
import { getErrorMessage } from "../../../shared/api/errors";
import { EmptyState } from "../../../shared/ui/EmptyState";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { PaginationControls } from "../../../shared/ui/PaginationControls";

export function CropNamesListPage() {
  const [includeArchived, setIncludeArchived] = useState(false);
  const [offset, setOffset] = useState(0);
  const query = useQuery({
    queryKey: ["crop-names", { includeArchived, offset }],
    queryFn: () =>
      listCropNames({
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
          <h1>Crop names</h1>
          <p className="lede">
            Catalog of crops you plant. Active names must be unique.
          </p>
        </div>
        <Link className="btn btn-primary" to="/crops/names/new">
          Add crop name
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
      {query.isLoading ? <LoadingState message="Loading crop names…" /> : null}

      {!query.isLoading && !query.isError && items.length === 0 ? (
        <EmptyState
          message="No crop names yet. Add rice, maize, or another crop to start."
          action={
            <Link className="btn btn-primary" to="/crops/names/new">
              Add crop name
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
                  <th scope="col">Notes</th>
                  <th scope="col">Status</th>
                </tr>
              </thead>
              <tbody>
                {items.map((name) => (
                  <tr key={name.id}>
                    <td>
                      <Link to={`/crops/names/${name.id}`}>{name.name}</Link>
                    </td>
                    <td>{name.notes ?? "—"}</td>
                    <td>{name.is_archived ? "Archived" : "Active"}</td>
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
            label="Crop names"
          />
        </>
      ) : null}
    </div>
  );
}
