import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createCow, uploadCowImage } from "../api/cowsApi";
import { CowForm } from "../components/CowForm";
import type { CowCreateInput } from "../types";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";

export function CowCreatePage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [error, setError] = useState<string | null>(null);

  const mutation = useMutation({
    mutationFn: async ({
      input,
      imageFile,
    }: {
      input: CowCreateInput;
      imageFile: File | null;
    }) => {
      const cow = await createCow(input);
      if (imageFile) {
        return uploadCowImage(cow.id, imageFile);
      }
      return cow;
    },
    onSuccess: async (cow) => {
      await queryClient.invalidateQueries({ queryKey: ["cows"] });
      navigate(`/cows/${cow.id}`);
    },
    onError: (err) => {
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(input: CowCreateInput, imageFile: File | null) {
    setError(null);
    mutation.mutate({ input, imageFile });
  }

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <h1>Add cow</h1>
      <p className="lede">Create a cow record for your farm.</p>
      <ErrorBanner message={error} />
      <CowForm
        submitLabel="Create cow"
        pending={mutation.isPending}
        onSubmit={onSubmit}
      />
    </div>
  );
}
