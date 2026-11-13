import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ApiError } from "../../../shared/api/errors";
import { SignInPage } from "./SignInPage";

const signIn = vi.fn();

vi.mock("../../../shared/auth/useAuth", () => ({
  useAuth: () => ({
    isSignedIn: false,
    signIn,
    signOut: vi.fn(),
    markSignedOut: vi.fn(),
  }),
}));

describe("SignInPage", () => {
  beforeEach(() => {
    signIn.mockReset();
  });

  it("shows the API message when credentials are invalid", async () => {
    const user = userEvent.setup();
    signIn.mockRejectedValue(
      new ApiError(401, {
        code: "INVALID_CREDENTIALS",
        message: "Email or password is incorrect.",
      }),
    );

    render(
      <MemoryRouter>
        <SignInPage />
      </MemoryRouter>,
    );

    await user.type(screen.getByLabelText("Email"), "owner@example.com");
    await user.type(screen.getByLabelText("Password"), "WrongPass1");
    await user.click(screen.getByRole("button", { name: "Sign in" }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        "Email or password is incorrect.",
      );
    });
  });

  it("redirects to /dashboard after a successful sign in", async () => {
    const user = userEvent.setup();
    signIn.mockResolvedValue(undefined);

    render(
      <MemoryRouter initialEntries={["/signin"]}>
        <Routes>
          <Route path="/signin" element={<SignInPage />} />
          <Route path="/dashboard" element={<div>Dashboard landing</div>} />
          <Route path="/profile" element={<div>Profile landing</div>} />
        </Routes>
      </MemoryRouter>,
    );

    await user.type(screen.getByLabelText("Email"), "owner@example.com");
    await user.type(screen.getByLabelText("Password"), "Password1");
    await user.click(screen.getByRole("button", { name: "Sign in" }));

    expect(await screen.findByText("Dashboard landing")).toBeInTheDocument();
    expect(screen.queryByText("Profile landing")).not.toBeInTheDocument();
  });
});
