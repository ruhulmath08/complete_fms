import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { createCropCycle, listCropNames } from "../api/cropsApi";
import { CropCycleForm } from "../components/CropCycleForm";
import type { CropCycleCreateInput } from "../types";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";

export function CropCycleCreatePage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);

  const namesQuery = useQuery({
    queryKey: ["crop-names", { includeArchived: false }],
    queryFn: () => listCropNames({ include_archived: false, limit: 100 }),
  });

  const mutation = useMutation({
    mutationFn: createCropCycle,
    onSuccess: async (cycle) => {
      await queryClient.invalidateQueries({ queryKey: ["crop-cycles"] });
      navigate(`/crops/cycles/${cycle.id}`);
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(input: CropCycleCreateInput) {
    setError(null);
    mutation.mutate(input);
  }

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <h1>Add crop cycle</h1>
      <p className="lede">
        Start a planting cycle using an active crop from your catalog.
      </p>
      <ErrorBanner message={error} />
      {namesQuery.isError ? (
        <ErrorBanner message={getErrorMessage(namesQuery.error)} />
      ) : null}
      {namesQuery.isLoading ? (
        <p className="muted">Loading crop names…</p>
      ) : null}
      {namesQuery.data && namesQuery.data.items.length === 0 ? (
        <p className="muted">
          No active crop names yet.{" "}
          <Link to="/crops/names/new">Add a crop name</Link> first.
        </p>
      ) : null}
      {namesQuery.data && namesQuery.data.items.length > 0 ? (
        <CropCycleForm
          cropNames={namesQuery.data.items}
          submitLabel="Create cycle"
          pending={mutation.isPending}
          onSubmit={onSubmit}
        />
      ) : null}
    </div>
  );
}
