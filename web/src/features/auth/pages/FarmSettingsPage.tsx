import { useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { getFarmSettings, updateFarmSettings } from "../api/authApi";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";

function SettingsForm({ initialCurrency }: { initialCurrency: string }) {
  const queryClient = useQueryClient();
  const [currencyCode, setCurrencyCode] = useState(initialCurrency);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  const mutation = useMutation({
    mutationFn: updateFarmSettings,
    onSuccess: async (data) => {
      setCurrencyCode(data.currency_code);
      setSaved(true);
      await queryClient.invalidateQueries({ queryKey: ["farm-settings"] });
    },
    onError: (err) => {
      setSaved(false);
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    setSaved(false);
    mutation.mutate(currencyCode);
  }

  return (
    <div className="panel" style={{ margin: "0 auto" }}>
      <h1>Farm settings</h1>
      <p className="lede">
        Single-farm currency preference used across records.
      </p>
      <ErrorBanner message={error} />
      {saved ? <p className="muted">Settings saved.</p> : null}
      <form className="form-stack" onSubmit={onSubmit}>
        <div className="field">
          <label htmlFor="currency_code">Currency code</label>
          <input
            id="currency_code"
            value={currencyCode}
            onChange={(e) => setCurrencyCode(e.target.value)}
            required
          />
        </div>
        <button
          className="btn btn-primary"
          type="submit"
          disabled={mutation.isPending}
        >
          {mutation.isPending ? "Saving…" : "Save settings"}
        </button>
      </form>
    </div>
  );
}

export function FarmSettingsPage() {
  const settingsQuery = useQuery({
    queryKey: ["farm-settings"],
    queryFn: getFarmSettings,
  });

  if (settingsQuery.isLoading)
    return <p className="muted">Loading farm settings…</p>;
  if (settingsQuery.isError) {
    return <ErrorBanner message={getErrorMessage(settingsQuery.error)} />;
  }
  if (!settingsQuery.data) return null;

  return (
    <SettingsForm
      key={settingsQuery.data.updated_at}
      initialCurrency={settingsQuery.data.currency_code}
    />
  );
}
