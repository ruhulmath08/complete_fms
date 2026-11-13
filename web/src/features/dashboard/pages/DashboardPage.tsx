import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { getDashboardAggregates } from "../api/dashboardApi";
import type { DashboardSeriesKey } from "../types";
import { getErrorMessage } from "../../../shared/api/errors";
import {
  grainForRange,
  normalizeRange,
  periodRange,
  todayIso,
  type PeriodKind,
  type PeriodRange,
} from "../../../shared/dates";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";
import { LoadingState } from "../../../shared/ui/LoadingState";
import { toChartNumber } from "../../../shared/ui/chartNumber";
import { SeriesChart } from "../../../shared/ui/SeriesChart";

type PeriodChoice = PeriodKind | "custom";

const PERIODS: { value: PeriodKind; label: string }[] = [
  { value: "day", label: "Day" },
  { value: "week", label: "Week" },
  { value: "month", label: "Month" },
  { value: "year", label: "Year" },
];

const CHARTS: { key: DashboardSeriesKey; title: string; color: string }[] = [
  { key: "egg_production", title: "Egg production", color: "#c4a35a" },
  { key: "hen_headcount", title: "Hen headcount", color: "#6b4f2a" },
  { key: "milk", title: "Milk", color: "#3b6ea5" },
  { key: "cow_production", title: "Cow production", color: "#2f6a3a" },
  { key: "expenses_cost", title: "Expenses cost", color: "#9b2c2c" },
  { key: "income", title: "Income", color: "#1f7a5a" },
];

export function DashboardPage() {
  const [period, setPeriod] = useState<PeriodChoice>("week");
  const [range, setRange] = useState<PeriodRange>(() => periodRange("week"));
  const [fromInput, setFromInput] = useState(range.from);
  const [toInput, setToInput] = useState(range.to);
  const maxDate = todayIso();

  const query = useQuery({
    queryKey: ["dashboard-aggregates", range],
    queryFn: () => getDashboardAggregates(range),
  });

  function selectPeriod(next: PeriodKind) {
    const nextRange = periodRange(next);
    setPeriod(next);
    setRange(nextRange);
    setFromInput(nextRange.from);
    setToInput(nextRange.to);
  }

  function applyCustom() {
    const normalized = normalizeRange(fromInput, toInput);
    setPeriod("custom");
    setFromInput(normalized.from);
    setToInput(normalized.to);
    setRange({
      ...normalized,
      grain: grainForRange(normalized.from, normalized.to),
    });
  }

  const series = query.data?.series;

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <div className="page-toolbar">
        <div>
          <h1>Dashboard</h1>
          <p className="lede">
            Farm production, headcount, costs and income over time
            {query.data?.timezone ? ` (${query.data.timezone})` : ""}.
          </p>
        </div>
      </div>

      <div
        className="period-controls"
        role="group"
        aria-label="Period"
      >
        {PERIODS.map((item) => (
          <button
            key={item.value}
            type="button"
            className={period === item.value ? "btn btn-primary" : "btn btn-ghost"}
            aria-pressed={period === item.value}
            onClick={() => selectPeriod(item.value)}
          >
            {item.label}
          </button>
        ))}
      </div>

      <div
        className="row-2"
        style={{ alignItems: "end", marginBottom: "1rem" }}
      >
        <div className="field">
          <label htmlFor="dashboard_from">From</label>
          <input
            id="dashboard_from"
            type="date"
            max={maxDate}
            value={fromInput}
            onChange={(e) => setFromInput(e.target.value)}
          />
        </div>
        <div className="field">
          <label htmlFor="dashboard_to">To</label>
          <input
            id="dashboard_to"
            type="date"
            max={maxDate}
            value={toInput}
            onChange={(e) => setToInput(e.target.value)}
          />
        </div>
      </div>
      <button type="button" className="btn btn-ghost" onClick={applyCustom}>
        Apply date range
      </button>

      <div style={{ marginTop: "1.5rem" }}>
        {query.isError ? (
          <ErrorBanner message={getErrorMessage(query.error)} />
        ) : null}
        {query.isLoading ? <LoadingState message="Loading dashboard…" /> : null}
        {series ? (
          <div className="dashboard-grid">
            {CHARTS.map((chart) => (
              <SeriesChart
                key={chart.key}
                title={chart.title}
                ariaLabel={`${chart.title} chart`}
                series={[
                  {
                    key: chart.key,
                    label: chart.title,
                    color: chart.color,
                    points: (series[chart.key] ?? []).map((p) => ({
                      x: p.bucket_start,
                      y: toChartNumber(p.value),
                    })),
                  },
                ]}
              />
            ))}
          </div>
        ) : null}
      </div>
    </div>
  );
}
