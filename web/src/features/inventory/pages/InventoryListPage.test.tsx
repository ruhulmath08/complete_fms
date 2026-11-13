import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ApiError } from "../../../shared/api/errors";
import { InventoryListPage } from "./InventoryListPage";

const listInventoryItems = vi.fn();
const listInventoryStockUpdates = vi.fn();

const emptyStock = { items: [], meta: { total: 0, limit: 10, offset: 0 } };

vi.mock("../api/inventoryApi", () => ({
  listInventoryItems: (...args: unknown[]) => listInventoryItems(...args),
  listInventoryStockUpdates: (...args: unknown[]) =>
    listInventoryStockUpdates(...args),
}));

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <InventoryListPage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("InventoryListPage", () => {
  beforeEach(() => {
    listInventoryItems.mockReset();
    listInventoryStockUpdates.mockReset();
    listInventoryStockUpdates.mockResolvedValue(emptyStock);
  });

  it("renders inventory items from the API", async () => {
    listInventoryItems.mockResolvedValue({
      items: [
        {
          id: "1",
          name: "Layer feed",
          category: "feed",
          quantity: "100.000",
          unit: "kg",
          price_per_unit: "50.00",
          total_price: "5000.00",
          note: null,
          is_archived: false,
          created_at: "2024-01-01T00:00:00Z",
          updated_at: "2024-01-01T00:00:00Z",
        },
      ],
      meta: { total: 1, limit: 10, offset: 0 },
    });

    renderPage();

    await waitFor(() => {
      expect(
        screen.getByRole("link", { name: "Layer feed" }),
      ).toBeInTheDocument();
    });
    expect(listInventoryItems).toHaveBeenCalledWith(
      expect.objectContaining({ limit: 10, offset: 0 }),
    );
    expect(screen.getByRole("link", { name: "Layer feed" })).toHaveAttribute(
      "href",
      "/inventory/1",
    );
    expect(screen.getByText("Feed")).toBeInTheDocument();
    expect(screen.getByText("100.000 kg")).toBeInTheDocument();
    expect(screen.getByText("5000.00")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /Add item/i })).toHaveAttribute(
      "href",
      "/inventory/new",
    );
  });

  it("shows the API message when listing fails", async () => {
    listInventoryItems.mockRejectedValue(
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
  const fertilizerRow = (n: number) => ({
    id: `u${n}`,
    inventory_item_id: "i9",
    item_name: "Urea",
    item_unit: "kg",
    item_category: "fertilizer",
    occurred_at: "2024-05-0" + n,
    change_type: n % 2 ? "add" : "use",
    quantity_change: "25.000",
    reason: n % 2 ? "Bought" : "Applied to plot",
    created_at: "2024-05-01T00:00:00Z",
  });

  it("shows fertilizer stock history with category filter and pagination", async () => {
    const user = userEvent.setup();
    listInventoryItems.mockResolvedValue({
      items: [],
      meta: { total: 0, limit: 10, offset: 0 },
    });
    listInventoryStockUpdates.mockImplementation(
      async (params: { offset?: number }) => ({
        items: [fertilizerRow(params.offset ? 2 : 1)],
        meta: { total: 11, limit: 10, offset: params.offset ?? 0 },
      }),
    );

    renderPage();

    const heading = await screen.findByRole("heading", {
      name: "Fertilizer stock history",
    });
    const section = within(heading.closest("section") as HTMLElement);
    await waitFor(() => {
      expect(
        section.getByRole("link", { name: "Urea" }),
      ).toHaveAttribute("href", "/inventory/i9");
    });
    expect(listInventoryStockUpdates).toHaveBeenCalledWith({
      category: "fertilizer",
      limit: 10,
      offset: 0,
    });
    expect(section.getByRole("columnheader", { name: "No." })).toBeInTheDocument();
    expect(section.getByText("25.000 kg")).toBeInTheDocument();
    expect(section.getByText("Bought")).toBeInTheDocument();

    await user.click(section.getByRole("button", { name: "Next" }));
    await waitFor(() => {
      expect(listInventoryStockUpdates).toHaveBeenCalledWith({
        category: "fertilizer",
        limit: 10,
        offset: 10,
      });
    });
    await waitFor(() => {
      expect(section.getByText("Applied to plot")).toBeInTheDocument();
    });
  });

  it("shows an empty state when there is no fertilizer history", async () => {
    listInventoryItems.mockResolvedValue({
      items: [],
      meta: { total: 0, limit: 10, offset: 0 },
    });

    renderPage();

    expect(
      await screen.findByText("No fertilizer stock updates yet."),
    ).toBeInTheDocument();
  });
});
