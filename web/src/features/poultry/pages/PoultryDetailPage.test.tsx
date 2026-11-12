import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { PoultryDetailPage } from "./PoultryDetailPage";

const getPoultryGroup = vi.fn();
const listEggProductions = vi.fn();
const listPoultryFeedings = vi.fn();
const getSuggestedUnits = vi.fn();
const updateEggProduction = vi.fn();
const deleteEggProduction = vi.fn();
const updatePoultryFeeding = vi.fn();
const deletePoultryFeeding = vi.fn();

vi.mock("../api/poultryApi", () => ({
  getPoultryGroup: (...args: unknown[]) => getPoultryGroup(...args),
  listEggProductions: (...args: unknown[]) => listEggProductions(...args),
  listPoultryFeedings: (...args: unknown[]) => listPoultryFeedings(...args),
  getSuggestedUnits: (...args: unknown[]) => getSuggestedUnits(...args),
  updateEggProduction: (...args: unknown[]) => updateEggProduction(...args),
  deleteEggProduction: (...args: unknown[]) => deleteEggProduction(...args),
  updatePoultryFeeding: (...args: unknown[]) => updatePoultryFeeding(...args),
  deletePoultryFeeding: (...args: unknown[]) => deletePoultryFeeding(...args),
  addEggProduction: vi.fn(),
  addPoultryFeeding: vi.fn(),
  updatePoultryGroup: vi.fn(),
  archivePoultryGroup: vi.fn(),
}));

const group = {
  id: "g1",
  poultry_type: "layer",
  name: "House A",
  bird_count: 100,
  date_acquired: null,
  acquired_by: "born_on_farm",
  purchase_date: null,
  purchase_price: null,
  notes: null,
  is_archived: false,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
};

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter initialEntries={["/poultry/g1"]}>
        <Routes>
          <Route path="/poultry/:groupId" element={<PoultryDetailPage />} />
        </Routes>
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("PoultryDetailPage actions", () => {
  beforeEach(() => {
    getPoultryGroup.mockReset();
    listEggProductions.mockReset();
    listPoultryFeedings.mockReset();
    getSuggestedUnits.mockReset();
    updateEggProduction.mockReset();
    deleteEggProduction.mockReset();
    updatePoultryFeeding.mockReset();
    deletePoultryFeeding.mockReset();

    getPoultryGroup.mockResolvedValue(group);
    getSuggestedUnits.mockResolvedValue(["pcs", "kg"]);
    listEggProductions.mockResolvedValue({
      items: [
        {
          id: "e1",
          poultry_group_id: "g1",
          produced_at: "2024-08-01T06:00:00Z",
          quantity: "80",
          unit: "pcs",
          price_per_unit: "12.00",
          note: "morning",
          created_at: "2024-08-01T06:00:00Z",
        },
      ],
      meta: { total: 1, limit: 10, offset: 0 },
    });
    listPoultryFeedings.mockResolvedValue({
      items: [
        {
          id: "f1",
          poultry_group_id: "g1",
          fed_at: "2024-08-01T08:00:00Z",
          feed_name: "Layer Mash",
          quantity: "10",
          unit: "kg",
          note: null,
          created_at: "2024-08-01T08:00:00Z",
        },
      ],
      meta: { total: 1, limit: 10, offset: 0 },
    });
  });

  it("shows No. headers and Action edit/delete for egg and feeding", async () => {
    renderPage();

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Edit egg entry" }),
      ).toBeInTheDocument();
    });
    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Edit feeding entry" }),
      ).toBeInTheDocument();
    });

    const eggHeading = screen.getByRole("heading", { name: "Egg production" });
    const eggSection = eggHeading.closest("section");
    expect(eggSection).not.toBeNull();
    expect(
      within(eggSection as HTMLElement).getByRole("columnheader", {
        name: "No.",
      }),
    ).toBeInTheDocument();
    expect(
      within(eggSection as HTMLElement).getByRole("columnheader", {
        name: "Action",
      }),
    ).toBeInTheDocument();
    expect(
      within(eggSection as HTMLElement).getByRole("button", {
        name: "Edit egg entry",
      }),
    ).toHaveClass("btn-icon-primary");
    expect(
      within(eggSection as HTMLElement).getByRole("button", {
        name: "Delete egg entry",
      }),
    ).toHaveClass("btn-icon-danger");

    const feedHeading = screen.getByRole("heading", { name: "Feeding" });
    const feedSection = feedHeading.closest("section");
    expect(feedSection).not.toBeNull();
    expect(
      within(feedSection as HTMLElement).getByRole("columnheader", {
        name: "No.",
      }),
    ).toBeInTheDocument();
    expect(
      within(feedSection as HTMLElement).getByRole("button", {
        name: "Edit feeding entry",
      }),
    ).toHaveClass("btn-icon-primary");
  });

  it("deletes an egg entry after confirm", async () => {
    const user = userEvent.setup();
    const confirmSpy = vi.spyOn(window, "confirm").mockReturnValue(true);
    deleteEggProduction.mockResolvedValue(undefined);
    listEggProductions
      .mockResolvedValueOnce({
        items: [
          {
            id: "e1",
            poultry_group_id: "g1",
            produced_at: "2024-08-01T06:00:00Z",
            quantity: "80",
            unit: "pcs",
            price_per_unit: "12.00",
            note: "morning",
            created_at: "2024-08-01T06:00:00Z",
          },
        ],
        meta: { total: 1, limit: 10, offset: 0 },
      })
      .mockResolvedValue({
        items: [],
        meta: { total: 0, limit: 10, offset: 0 },
      });

    renderPage();
    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Delete egg entry" }),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: "Delete egg entry" }));
    await waitFor(() => {
      expect(deleteEggProduction).toHaveBeenCalledWith("g1", "e1");
    });
    confirmSpy.mockRestore();
  });

  it("hides Action when the group is archived", async () => {
    getPoultryGroup.mockResolvedValue({ ...group, is_archived: true });
    renderPage();

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: "House A" })).toBeInTheDocument();
    });

    expect(
      screen.queryByRole("button", { name: "Edit egg entry" }),
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole("button", { name: "Delete feeding entry" }),
    ).not.toBeInTheDocument();
  });
});
