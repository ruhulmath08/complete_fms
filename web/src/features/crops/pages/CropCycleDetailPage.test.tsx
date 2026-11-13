import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { CropCycleDetailPage } from "./CropCycleDetailPage";

const getCropCycle = vi.fn();
const getCropCycleSummary = vi.fn();
const listCropNames = vi.fn();
const listCropExpenses = vi.fn();
const listHarvests = vi.fn();
const getSuggestedUnits = vi.fn();
const updateCropExpense = vi.fn();
const deleteCropExpense = vi.fn();
const updateHarvest = vi.fn();
const deleteHarvest = vi.fn();

vi.mock("../api/cropsApi", () => ({
  getCropCycle: (...args: unknown[]) => getCropCycle(...args),
  getCropCycleSummary: (...args: unknown[]) => getCropCycleSummary(...args),
  listCropNames: (...args: unknown[]) => listCropNames(...args),
  listCropExpenses: (...args: unknown[]) => listCropExpenses(...args),
  listHarvests: (...args: unknown[]) => listHarvests(...args),
  getSuggestedUnits: (...args: unknown[]) => getSuggestedUnits(...args),
  updateCropExpense: (...args: unknown[]) => updateCropExpense(...args),
  deleteCropExpense: (...args: unknown[]) => deleteCropExpense(...args),
  updateHarvest: (...args: unknown[]) => updateHarvest(...args),
  deleteHarvest: (...args: unknown[]) => deleteHarvest(...args),
  addCropExpense: vi.fn(),
  addHarvest: vi.fn(),
  archiveCropCycle: vi.fn(),
  updateCropCycle: vi.fn(),
}));

const cycle = {
  id: "c1",
  crop_name_id: "n1",
  plot_name: "Plot A",
  area: null,
  location: null,
  planted_at: "2024-03-01",
  expected_harvest_at: null,
  notes: null,
  is_archived: false,
  created_at: "2024-03-01T00:00:00Z",
  updated_at: "2024-03-01T00:00:00Z",
};

const expense = {
  id: "x1",
  crop_cycle_id: "c1",
  spent_at: "2024-03-05",
  category: "seeds",
  amount: "120.00",
  note: "first batch",
  created_at: "2024-03-05T00:00:00Z",
};

const harvest = {
  id: "h1",
  crop_cycle_id: "c1",
  harvested_at: "2024-06-01",
  quantity: "50",
  unit: "kg",
  sale_amount: "400.00",
  note: null,
  created_at: "2024-06-01T00:00:00Z",
};

function page<T>(items: T[]) {
  return { items, meta: { total: items.length, limit: 10, offset: 0 } };
}

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter initialEntries={["/crops/cycles/c1"]}>
        <Routes>
          <Route
            path="/crops/cycles/:cycleId"
            element={<CropCycleDetailPage />}
          />
        </Routes>
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

function section(name: string): HTMLElement {
  const el = screen.getByRole("heading", { name }).closest("section");
  expect(el).not.toBeNull();
  return el as HTMLElement;
}

describe("CropCycleDetailPage expense/harvest actions", () => {
  beforeEach(() => {
    [
      getCropCycle,
      getCropCycleSummary,
      listCropNames,
      listCropExpenses,
      listHarvests,
      getSuggestedUnits,
      updateCropExpense,
      deleteCropExpense,
      updateHarvest,
      deleteHarvest,
    ].forEach((m) => m.mockReset());

    getCropCycle.mockResolvedValue(cycle);
    getCropCycleSummary.mockResolvedValue({
      crop_cycle_id: "c1",
      total_expenses: "120.00",
      total_sale_income: "400.00",
      result: "280.00",
    });
    listCropNames.mockResolvedValue(
      page([
        {
          id: "n1",
          name: "Tomato",
          notes: null,
          is_archived: false,
          created_at: "2024-01-01T00:00:00Z",
          updated_at: "2024-01-01T00:00:00Z",
        },
      ]),
    );
    getSuggestedUnits.mockResolvedValue(["kg"]);
    listCropExpenses.mockResolvedValue(page([expense]));
    listHarvests.mockResolvedValue(page([harvest]));
  });

  it("shows Action column with Edit primary and Delete danger buttons", async () => {
    renderPage();

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Edit expense" }),
      ).toBeInTheDocument();
    });
    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Edit harvest" }),
      ).toBeInTheDocument();
    });

    const expenses = within(section("Expenses"));
    expect(
      expenses.getByRole("columnheader", { name: "Action" }),
    ).toBeInTheDocument();
    expect(expenses.getByRole("button", { name: "Edit expense" })).toHaveClass(
      "btn-icon-primary",
    );
    expect(
      expenses.getByRole("button", { name: "Delete expense" }),
    ).toHaveClass("btn-icon-danger");

    const harvests = within(section("Harvests"));
    expect(
      harvests.getByRole("columnheader", { name: "Action" }),
    ).toBeInTheDocument();
    expect(harvests.getByRole("button", { name: "Edit harvest" })).toHaveClass(
      "btn-icon-primary",
    );
    expect(
      harvests.getByRole("button", { name: "Delete harvest" }),
    ).toHaveClass("btn-icon-danger");
  });

  it("edits an expense via PATCH payload", async () => {
    const user = userEvent.setup();
    updateCropExpense.mockResolvedValue({ ...expense, amount: "150.00" });
    renderPage();

    await user.click(
      await screen.findByRole("button", { name: "Edit expense" }),
    );
    const amount = screen.getByLabelText("Amount");
    expect(amount).toHaveValue("120.00");
    await user.clear(amount);
    await user.type(amount, "150.00");
    await user.click(screen.getByRole("button", { name: "Update expense" }));

    await waitFor(() => {
      expect(updateCropExpense).toHaveBeenCalledWith(
        "c1",
        "x1",
        expect.objectContaining({
          spent_at: "2024-03-05",
          category: "seeds",
          amount: "150.00",
          note: "first batch",
        }),
      );
    });
  });

  it("deletes an expense after confirm", async () => {
    const user = userEvent.setup();
    const confirmSpy = vi.spyOn(window, "confirm").mockReturnValue(true);
    deleteCropExpense.mockResolvedValue(undefined);
    renderPage();

    await user.click(
      await screen.findByRole("button", { name: "Delete expense" }),
    );
    await waitFor(() => {
      expect(deleteCropExpense).toHaveBeenCalledWith("c1", "x1");
    });
    confirmSpy.mockRestore();
  });

  it("does not delete an expense when confirm is cancelled", async () => {
    const user = userEvent.setup();
    const confirmSpy = vi.spyOn(window, "confirm").mockReturnValue(false);
    renderPage();

    await user.click(
      await screen.findByRole("button", { name: "Delete expense" }),
    );
    expect(deleteCropExpense).not.toHaveBeenCalled();
    confirmSpy.mockRestore();
  });

  it("edits a harvest and clears an empty sale amount to null", async () => {
    const user = userEvent.setup();
    updateHarvest.mockResolvedValue(harvest);
    renderPage();

    await user.click(
      await screen.findByRole("button", { name: "Edit harvest" }),
    );
    const sale = screen.getByLabelText("Sale amount (optional)");
    expect(sale).toHaveValue("400.00");
    await user.clear(sale);
    await user.click(screen.getByRole("button", { name: "Update harvest" }));

    await waitFor(() => {
      expect(updateHarvest).toHaveBeenCalledWith(
        "c1",
        "h1",
        expect.objectContaining({
          harvested_at: "2024-06-01",
          quantity: "50",
          unit: "kg",
          sale_amount: null,
        }),
      );
    });
  });

  it("deletes a harvest after confirm", async () => {
    const user = userEvent.setup();
    const confirmSpy = vi.spyOn(window, "confirm").mockReturnValue(true);
    deleteHarvest.mockResolvedValue(undefined);
    renderPage();

    await user.click(
      await screen.findByRole("button", { name: "Delete harvest" }),
    );
    await waitFor(() => {
      expect(deleteHarvest).toHaveBeenCalledWith("c1", "h1");
    });
    confirmSpy.mockRestore();
  });

  it("hides Action when the cycle is archived", async () => {
    getCropCycle.mockResolvedValue({ ...cycle, is_archived: true });
    renderPage();

    await waitFor(() => {
      expect(screen.getByText("120.00", { selector: "td" })).toBeInTheDocument();
    });
    expect(
      screen.queryByRole("button", { name: "Edit expense" }),
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole("button", { name: "Delete harvest" }),
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole("columnheader", { name: "Action" }),
    ).not.toBeInTheDocument();
  });
});
