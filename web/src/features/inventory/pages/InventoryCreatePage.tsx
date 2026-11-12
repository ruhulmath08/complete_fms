import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createInventoryItem } from "../api/inventoryApi";
import { InventoryItemForm } from "../components/InventoryItemForm";
import type { InventoryItemCreateInput } from "../types";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";

export function InventoryCreatePage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);

  const mutation = useMutation({
    mutationFn: createInventoryItem,
    onSuccess: async (item) => {
      await queryClient.invalidateQueries({ queryKey: ["inventory-items"] });
      navigate(`/inventory/${item.id}`);
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(input: InventoryItemCreateInput) {
    setError(null);
    mutation.mutate(input);
  }

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <h1>Add inventory item</h1>
      <p className="lede">
        Set the opening quantity here. Later changes use stock add or use
        updates.
      </p>
      <ErrorBanner message={error} />
      <InventoryItemForm
        mode="create"
        submitLabel="Create item"
        pending={mutation.isPending}
        onSubmit={(input) => onSubmit(input as InventoryItemCreateInput)}
      />
    </div>
  );
}
