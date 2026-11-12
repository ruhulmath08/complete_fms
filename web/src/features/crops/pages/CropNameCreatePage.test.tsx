import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ApiError } from "../../../shared/api/errors";
import { CropNameCreatePage } from "./CropNameCreatePage";

const createCropName = vi.fn();

vi.mock("../api/cropsApi", () => ({
  createCropName: (...args: unknown[]) => createCropName(...args),
}));

function renderPage() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <CropNameCreatePage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("CropNameCreatePage", () => {
  beforeEach(() => {
    createCropName.mockReset();
  });

  it("shows the API message when the crop name already exists", async () => {
    const user = userEvent.setup();
    createCropName.mockRejectedValue(
      new ApiError(409, {
        code: "CROP_NAME_ALREADY_EXISTS",
        message: "An active crop name with this name already exists.",
      }),
    );

    renderPage();

    await user.type(screen.getByLabelText("Crop name"), "Rice");
    await user.click(screen.getByRole("button", { name: "Create crop name" }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        "An active crop name with this name already exists.",
      );
    });
    expect(createCropName).toHaveBeenCalled();
    expect(createCropName.mock.calls[0][0]).toEqual({
      name: "Rice",
      notes: null,
    });
  });
});
