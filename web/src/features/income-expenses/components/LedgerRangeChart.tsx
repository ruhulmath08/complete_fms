import { useQuery } from "@tanstack/react-query";
import { getLedgerSeries } from "../api/ledgerApi";
import { getErrorMessage } from "../../../shared/api/errors";
import { grainForRange, normalizeRange } from "../../../shared/dates";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { toChartNumber } from "../../../shared/ui/chartNumber";
import { SeriesChart } from "../../../shared/ui/SeriesChart";

type LedgerRangeChartProps = {
  from: string;
  to: string;
};

export function LedgerRangeChart({ from, to }: LedgerRangeChartProps) {
  const range = normalizeRange(from, to);
  const grain = grainForRange(range.from, range.to);

  const query = useQuery({
    queryKey: ["ledger-series", { ...range, grain }],
    queryFn: () => getLedgerSeries({ ...range, grain }),
  });

  if (query.isError) {
    return <ErrorBanner message={getErrorMessage(query.error)} />;
  }
  if (query.isLoading) return <LoadingState message="Loading chart…" />;

  const points = query.data?.points ?? [];
  return (
    <SeriesChart
      title="Income and expenses over time"
      ariaLabel="Income, expenses and net over the selected date range"
      emptyMessage="No ledger activity in this range."
      series={[
        {
          key: "income",
          label: "Income",
          color: "#2f6a3a",
          points: points.map((p) => ({
            x: p.bucket_start,
            y: toChartNumber(p.income),
          })),
        },
        {
          key: "expenses",
          label: "Expenses",
          color: "#9b2c2c",
          points: points.map((p) => ({
            x: p.bucket_start,
            y: toChartNumber(p.expenses),
          })),
        },
        {
          key: "net",
          label: "Net",
          color: "#c4a35a",
          points: points.map((p) => ({
            x: p.bucket_start,
            y: toChartNumber(p.net),
          })),
        },
      ]}
    />
  );
}
