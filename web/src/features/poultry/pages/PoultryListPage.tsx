import { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { listPoultryGroups } from "../api/poultryApi";
import { DEFAULT_PAGE_SIZE } from "../../../shared/constants/pagination";
import { getErrorMessage } from "../../../shared/api/errors";
import { EmptyState } from "../../../shared/ui/EmptyState";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { PaginationControls } from "../../../shared/ui/PaginationControls";

export function PoultryListPage() {
  const [includeArchived, setIncludeArchived] = useState(false);
  const [offset, setOffset] = useState(0);
  const query = useQuery({
    queryKey: ["poultry-groups", { includeArchived, offset }],
    queryFn: () =>
      listPoultryGroups({
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
          <h1>Poultry</h1>
          <p className="lede">
            Groups for broilers, ducks, layers, and local birds.
          </p>
        </div>
        <Link className="btn btn-primary" to="/poultry/new">
          Add group
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
      {query.isLoading ? (
        <LoadingState message="Loading poultry groups…" />
      ) : null}

      {!query.isLoading && !query.isError && items.length === 0 ? (
        <EmptyState
          message="No poultry groups yet. Add your first group to get started."
          action={
            <Link className="btn btn-primary" to="/poultry/new">
              Add group
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
                  <th scope="col">Type</th>
                  <th scope="col">Birds</th>
                  <th scope="col">Status</th>
                </tr>
              </thead>
              <tbody>
                {items.map((group) => (
                  <tr key={group.id}>
                    <td>
                      <Link to={`/poultry/${group.id}`}>{group.name}</Link>
                    </td>
                    <td>{group.poultry_type}</td>
                    <td>{group.bird_count}</td>
                    <td>{group.is_archived ? "Archived" : "Active"}</td>
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
            label="Poultry"
          />
        </>
      ) : null}
    </div>
  );
}
