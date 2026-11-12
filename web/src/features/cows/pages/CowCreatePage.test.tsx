import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ApiError } from "../../../shared/api/errors";
import { CowCreatePage } from "./CowCreatePage";

const createCow = vi.fn();
const uploadCowImage = vi.fn();

vi.mock("../api/cowsApi", () => ({
  createCow: (...args: unknown[]) => createCow(...args),
  uploadCowImage: (...args: unknown[]) => uploadCowImage(...args),
}));

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <CowCreatePage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("CowCreatePage", () => {
  beforeEach(() => {
    createCow.mockReset();
    uploadCowImage.mockReset();
  });

  it("shows the API message when create fails", async () => {
    const user = userEvent.setup();
    createCow.mockRejectedValue(
      new ApiError(422, {
        code: "VALIDATION_ERROR",
        message: "Name is required.",
      }),
    );

    renderPage();

    await user.type(screen.getByLabelText("Name"), "Bella");
    await user.type(screen.getByLabelText("Breed"), "Holstein");
    await user.click(screen.getByRole("button", { name: "Create cow" }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent("Name is required.");
    });
    expect(createCow).toHaveBeenCalled();
  });
});
