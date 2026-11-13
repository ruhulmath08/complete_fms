import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { todayIso } from "../../../shared/dates";
import { ApiError } from "../../../shared/api/errors";
import { LedgerListPage } from "./LedgerListPage";

const listLedgerEntries = vi.fn();
const getPeriodTotals = vi.fn();
const getLedgerSeries = vi.fn();

vi.mock("../api/ledgerApi", () => ({
  listLedgerEntries: (...args: unknown[]) => listLedgerEntries(...args),
  getPeriodTotals: (...args: unknown[]) => getPeriodTotals(...args),
  getLedgerSeries: (...args: unknown[]) => getLedgerSeries(...args),
}));

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <LedgerListPage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("LedgerListPage", () => {
  beforeEach(() => {
    listLedgerEntries.mockReset();
    getPeriodTotals.mockReset();
    getLedgerSeries.mockReset();
    getLedgerSeries.mockResolvedValue({
      from: "2024-06-01",
      to: "2024-06-30",
      grain: "day",
      points: [
        { bucket_start: "2024-06-01", income: "0.00", expenses: "0.00", net: "0.00" },
        { bucket_start: "2024-06-02", income: "100.00", expenses: "30.00", net: "70.00" },
      ],
    });
    getPeriodTotals.mockResolvedValue({
      from: "2024-06-01",
      to: "2024-06-30",
      total_income: "200.00",
      total_expenses: "50.00",
      net: "150.00",
    });
  });

  it("renders ledger entries and period totals from the API", async () => {
    listLedgerEntries.mockResolvedValue({
      items: [
        {
          id: "1",
          entry_type: "income",
          occurred_at: "2024-06-15",
          category: "product_sale",
          amount: "100.00",
          unit: null,
          total_price: "100.00",
          note: null,
          is_archived: false,
          created_at: "2024-06-15T00:00:00Z",
          updated_at: "2024-06-15T00:00:00Z",
        },
      ],
      meta: { total: 1, limit: 10, offset: 0 },
    });

    renderPage();

    await waitFor(() => {
      expect(screen.getByRole("table")).toBeInTheDocument();
    });
    expect(listLedgerEntries).toHaveBeenCalledWith(
      expect.objectContaining({ limit: 10, offset: 0 }),
    );
    expect(screen.getByRole("link", { name: "2024-06-15" })).toHaveAttribute(
      "href",
      "/ledger/1",
    );
    expect(screen.getByText("Income", { selector: "td" })).toBeInTheDocument();
    expect(screen.getByText("Product sale")).toBeInTheDocument();
    expect(screen.getByText("100.00")).toBeInTheDocument();
    expect(screen.getByText("200.00")).toBeInTheDocument();
    expect(screen.getByText("50.00")).toBeInTheDocument();
    expect(screen.getByText("150.00")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /Add entry/i })).toHaveAttribute(
      "href",
      "/ledger/new",
    );
  });

  it("shows the API message when listing fails", async () => {
    listLedgerEntries.mockRejectedValue(
      new ApiError(401, {
        code: "UNAUTHORIZED",
        message: "Authentication required.",
      }),
    );

    renderPage();

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        "Authentication required.",
      );
    });
  });
  it("renders the series chart below Apply and keeps numeric totals", async () => {
    listLedgerEntries.mockResolvedValue({
      items: [],
      meta: { total: 0, limit: 10, offset: 0 },
    });

    renderPage();

    const chart = await screen.findByRole("img", {
      name: /income, expenses and net/i,
    });
    const apply = screen.getByRole("button", { name: "Apply date range" });
    // chart follows the Apply button in document order
    expect(
      apply.compareDocumentPosition(chart) & Node.DOCUMENT_POSITION_FOLLOWING,
    ).toBeTruthy();
    const legend = within(screen.getByRole("list", { name: "Legend" }));
    expect(legend.getByText("Income")).toBeInTheDocument();
    expect(legend.getByText("Expenses")).toBeInTheDocument();
    expect(legend.getByText("Net")).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText("200.00")).toBeInTheDocument();
    });
    expect(screen.getByText("Total income")).toBeInTheDocument();
    expect(getLedgerSeries).toHaveBeenCalledWith(
      expect.objectContaining({ grain: "day" }),
    );
  });

  it("refetches the series for the applied range, clamped to today", async () => {
    const user = userEvent.setup();
    listLedgerEntries.mockResolvedValue({
      items: [],
      meta: { total: 0, limit: 10, offset: 0 },
    });

    renderPage();
    await screen.findByRole("img", { name: /income, expenses and net/i });

    const from = screen.getByLabelText("From");
    const to = screen.getByLabelText("To");
    await user.clear(from);
    await user.type(from, "2020-01-01");
    await user.clear(to);
    await user.type(to, "2020-12-31");
    await user.click(screen.getByRole("button", { name: "Apply date range" }));

    await waitFor(() => {
      expect(getLedgerSeries).toHaveBeenCalledWith({
        from: "2020-01-01",
        to: "2020-12-31",
        grain: "month",
      });
    });

    await user.clear(to);
    await user.type(to, "2999-12-31");
    await user.click(screen.getByRole("button", { name: "Apply date range" }));
    await waitFor(() => {
      const last = getLedgerSeries.mock.calls.at(-1)?.[0] as { to: string };
      expect(last.to).toBe(todayIso());
      expect(last.to).not.toBe("2999-12-31");
    });
  });

  it("shows an error banner when the series request fails", async () => {
    listLedgerEntries.mockResolvedValue({
      items: [],
      meta: { total: 0, limit: 10, offset: 0 },
    });
    getLedgerSeries.mockRejectedValue(
      new ApiError(422, { code: "FUTURE_DATE_NOT_ALLOWED", message: "No future dates." }),
    );

    renderPage();

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent("No future dates.");
    });
  });
});
