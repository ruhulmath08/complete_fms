import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { ApiError } from "../../../shared/api/errors";
import { todayIso, weekStartIso } from "../../../shared/dates";
import { DashboardPage } from "./DashboardPage";

const getDashboardAggregates = vi.fn();

vi.mock("../api/dashboardApi", () => ({
  getDashboardAggregates: (...args: unknown[]) =>
    getDashboardAggregates(...args),
}));

function points(values: string[]) {
  return values.map((value, i) => ({
    bucket_start: `2026-11-0${i + 1}`,
    value,
  }));
}

const aggregates = {
  from: "2026-11-09",
  to: "2026-11-13",
  grain: "day",
  timezone: "Asia/Dhaka",
  series: {
    egg_production: points(["10", "12"]),
    hen_headcount: points(["100", "100"]),
    milk: points(["5.5", "6.0"]),
    cow_production: points(["3", "4"]),
    expenses_cost: points(["40.00", "0.00"]),
    income: points(["100.00", "20.00"]),
  },
};

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <DashboardPage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("DashboardPage", () => {
  beforeEach(() => {
    getDashboardAggregates.mockReset();
    getDashboardAggregates.mockResolvedValue(aggregates);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("loads this week (Monday to today, daily) by default and renders six charts", async () => {
    renderPage();

    await waitFor(() => {
      expect(getDashboardAggregates).toHaveBeenCalledWith({
        from: weekStartIso(),
        to: todayIso(),
        grain: "day",
      });
    });
    expect(screen.getByRole("button", { name: "Week" })).toHaveAttribute(
      "aria-pressed",
      "true",
    );

    for (const name of [
      "Egg production chart",
      "Hen headcount chart",
      "Milk chart",
      "Cow production chart",
      "Expenses cost chart",
      "Income chart",
    ]) {
      expect(await screen.findByRole("img", { name })).toBeInTheDocument();
    }
    expect(screen.getByText(/Asia\/Dhaka/)).toBeInTheDocument();
  });

  it("caps date inputs at today", async () => {
    renderPage();
    await screen.findByRole("img", { name: "Income chart" });

    expect(screen.getByLabelText("From")).toHaveAttribute("max", todayIso());
    expect(screen.getByLabelText("To")).toHaveAttribute("max", todayIso());
  });

  it("switches period and refetches with the matching range and grain", async () => {
    const user = userEvent.setup();
    renderPage();
    await screen.findByRole("img", { name: "Income chart" });

    await user.click(screen.getByRole("button", { name: "Year" }));
    await waitFor(() => {
      expect(getDashboardAggregates).toHaveBeenLastCalledWith({
        from: `${new Date().getFullYear()}-01-01`,
        to: todayIso(),
        grain: "month",
      });
    });
    expect(screen.getByRole("button", { name: "Year" })).toHaveAttribute(
      "aria-pressed",
      "true",
    );

    await user.click(screen.getByRole("button", { name: "Day" }));
    await waitFor(() => {
      expect(getDashboardAggregates).toHaveBeenLastCalledWith({
        from: todayIso(),
        to: todayIso(),
        grain: "day",
      });
    });
  });

  it("clamps a custom range to today when applied", async () => {
    const user = userEvent.setup();
    renderPage();
    await screen.findByRole("img", { name: "Income chart" });

    const to = screen.getByLabelText("To");
    await user.clear(to);
    await user.type(to, "2999-12-31");
    await user.click(screen.getByRole("button", { name: "Apply date range" }));

    await waitFor(() => {
      const last = getDashboardAggregates.mock.calls.at(-1)?.[0] as {
        to: string;
      };
      expect(last.to).toBe(todayIso());
    });
  });

  it("shows the API error message when loading fails", async () => {
    getDashboardAggregates.mockRejectedValue(
      new ApiError(422, {
        code: "FUTURE_DATE_NOT_ALLOWED",
        message: "Future dates are not allowed.",
      }),
    );
    renderPage();

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        "Future dates are not allowed.",
      );
    });
  });
});
