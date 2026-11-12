import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ApiError } from "../../../shared/api/errors";
import { PoultryCreatePage } from "./PoultryCreatePage";

const createPoultryGroup = vi.fn();

vi.mock("../api/poultryApi", () => ({
  createPoultryGroup: (...args: unknown[]) => createPoultryGroup(...args),
}));

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <PoultryCreatePage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("PoultryCreatePage", () => {
  beforeEach(() => {
    createPoultryGroup.mockReset();
  });

  it("shows the API message when purchase fields are invalid", async () => {
    const user = userEvent.setup();
    createPoultryGroup.mockRejectedValue(
      new ApiError(422, {
        code: "PURCHASE_FIELDS_INVALID",
        message:
          "Purchase date and price are required when acquired by purchase.",
      }),
    );

    renderPage();

    await user.clear(screen.getByLabelText("Group name"));
    await user.type(screen.getByLabelText("Group name"), "Broilers");
    await user.selectOptions(screen.getByLabelText("Acquired by"), "purchased");
    await user.type(screen.getByLabelText("Purchase date"), "2024-06-01");
    await user.type(screen.getByLabelText("Purchase price"), "100");
    await user.click(screen.getByRole("button", { name: "Create group" }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        "Purchase date and price are required when acquired by purchase.",
      );
    });
    expect(createPoultryGroup).toHaveBeenCalled();
  });
});
