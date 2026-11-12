import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createPoultryGroup } from "../api/poultryApi";
import { PoultryGroupForm } from "../components/PoultryGroupForm";
import type { PoultryGroupCreateInput } from "../types";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";

export function PoultryCreatePage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);

  const mutation = useMutation({
    mutationFn: createPoultryGroup,
    onSuccess: async (group) => {
      await queryClient.invalidateQueries({ queryKey: ["poultry-groups"] });
      navigate(`/poultry/${group.id}`);
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(input: PoultryGroupCreateInput) {
    setError(null);
    mutation.mutate(input);
  }

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <h1>Add poultry group</h1>
      <p className="lede">
        Create a group record for your farm. Names do not need to be unique.
      </p>
      <ErrorBanner message={error} />
      <PoultryGroupForm
        submitLabel="Create group"
        pending={mutation.isPending}
        onSubmit={onSubmit}
      />
    </div>
  );
}
