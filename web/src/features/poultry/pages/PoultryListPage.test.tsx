import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ApiError } from "../../../shared/api/errors";
import { PoultryListPage } from "./PoultryListPage";

const listPoultryGroups = vi.fn();

vi.mock("../api/poultryApi", () => ({
  listPoultryGroups: (...args: unknown[]) => listPoultryGroups(...args),
}));

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <PoultryListPage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("PoultryListPage", () => {
  beforeEach(() => {
    listPoultryGroups.mockReset();
  });

  it("renders poultry groups from the API", async () => {
    listPoultryGroups.mockResolvedValue({
      items: [
        {
          id: "1",
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
        },
      ],
      meta: { total: 1, limit: 10, offset: 0 },
    });

    renderPage();

    await waitFor(() => {
      expect(screen.getByRole("table")).toBeInTheDocument();
    });
    expect(listPoultryGroups).toHaveBeenCalledWith(
      expect.objectContaining({ limit: 10, offset: 0 }),
    );
    expect(screen.getByRole("link", { name: "House A" })).toHaveAttribute(
      "href",
      "/poultry/1",
    );
    expect(screen.getByText("layer")).toBeInTheDocument();
    expect(screen.getByText("100")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /Add group/i })).toHaveAttribute(
      "href",
      "/poultry/new",
    );
  });

  it("shows the API message when listing fails", async () => {
    listPoultryGroups.mockRejectedValue(
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
});
