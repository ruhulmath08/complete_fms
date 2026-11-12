import { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { listCows } from "../api/cowsApi";
import { DEFAULT_PAGE_SIZE } from "../../../shared/constants/pagination";
import { getErrorMessage } from "../../../shared/api/errors";
import { EmptyState } from "../../../shared/ui/EmptyState";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { PaginationControls } from "../../../shared/ui/PaginationControls";

export function CowsListPage() {
  const [includeArchived, setIncludeArchived] = useState(false);
  const [offset, setOffset] = useState(0);
  const query = useQuery({
    queryKey: ["cows", { includeArchived, offset }],
    queryFn: () =>
      listCows({
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
          <h1>Cows</h1>
          <p className="lede">Active herd records for milk and feeding.</p>
        </div>
        <Link className="btn btn-primary" to="/cows/new">
          Add cow
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
      {query.isLoading ? <LoadingState message="Loading cows…" /> : null}

      {!query.isLoading && !query.isError && items.length === 0 ? (
        <EmptyState
          message="No cows yet. Add your first cow to get started."
          action={
            <Link className="btn btn-primary" to="/cows/new">
              Add cow
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
                  <th scope="col">Tag</th>
                  <th scope="col">Name</th>
                  <th scope="col">Purpose</th>
                  <th scope="col">Gender</th>
                  <th scope="col">Status</th>
                </tr>
              </thead>
              <tbody>
                {items.map((cow) => (
                  <tr key={cow.id}>
                    <td>
                      <Link to={`/cows/${cow.id}`}>{cow.tag_number}</Link>
                    </td>
                    <td>{cow.name ?? "—"}</td>
                    <td>{cow.purpose}</td>
                    <td>{cow.gender}</td>
                    <td>{cow.is_archived ? "Archived" : "Active"}</td>
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
            label="Cows"
          />
        </>
      ) : null}
    </div>
  );
}
