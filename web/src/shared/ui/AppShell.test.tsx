import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { AppShell } from "./AppShell";

vi.mock("../auth/useAuth", () => ({
  useAuth: () => ({
    isSignedIn: true,
    signIn: vi.fn(),
    signOut: vi.fn(),
    markSignedOut: vi.fn(),
  }),
}));

vi.mock("../../features/auth/api/authApi", () => ({
  getProfile: vi.fn(async () => ({
    id: "owner-1",
    full_name: "Ada Owner",
    email: "ada@example.com",
    phone: "+8801711111111",
    address: "Dhaka",
    latitude: 23.7,
    longitude: 90.4,
    profile_image_url: "/api/v1/me/profile-image",
    created_at: "2026-01-01T00:00:00Z",
    updated_at: "2026-01-01T00:00:00Z",
  })),
}));

vi.mock("../../features/auth/hooks/useProfileImageUrl", () => ({
  useProfileImageUrl: () => null,
}));

function renderShell() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter initialEntries={["/"]}>
        <Routes>
          <Route element={<AppShell />}>
            <Route path="/" element={<div>Home body</div>} />
            <Route path="/dashboard" element={<div>Dashboard body</div>} />
            <Route path="/cows" element={<div>Cows body</div>} />
            <Route path="/profile" element={<div>Profile body</div>} />
          </Route>
        </Routes>
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("AppShell", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it("renders left menu destinations, header chrome, and footer", async () => {
    renderShell();

    expect(await screen.findByRole("navigation")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Dashboard" })).toHaveAttribute(
      "href",
      "/dashboard",
    );
    expect(screen.getByRole("link", { name: "Farm Manager" })).toHaveAttribute(
      "href",
      "/dashboard",
    );
    expect(screen.getByRole("link", { name: "Cows" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Poultry" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Crops" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Inventory" })).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: "Income & expenses" }),
    ).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Profile" })).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: "Farm settings" }),
    ).toBeInTheDocument();

    expect(
      screen.getByRole("button", { name: "Notifications" }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "Open profile menu" }),
    ).toBeInTheDocument();
    expect(await screen.findByText("AO")).toBeInTheDocument();
    expect(screen.getByText("Home body")).toBeInTheDocument();
    expect(screen.getByText("Single-farm record keeping")).toBeInTheDocument();
    expect(
      screen.queryByRole("button", { name: "Sign out" }),
    ).not.toBeInTheDocument();
  });

  it("opens profile menu with Profile and Logout", async () => {
    const user = userEvent.setup();
    renderShell();

    await user.click(
      await screen.findByRole("button", { name: "Open profile menu" }),
    );
    expect(
      screen.getByRole("menuitem", { name: "Profile" }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("menuitem", { name: "Logout" }),
    ).toBeInTheDocument();
    expect(screen.getByText("Ada Owner")).toBeInTheDocument();
  });

  it("toggles the sidebar menu", async () => {
    const user = userEvent.setup();
    renderShell();

    const hide = await screen.findByRole("button", { name: "Hide menu" });
    await user.click(hide);
    expect(screen.queryByRole("navigation")).not.toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "Show menu" }),
    ).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Show menu" }));
    expect(screen.getByRole("navigation")).toBeInTheDocument();
  });

  it("shows an empty notifications placeholder", async () => {
    const user = userEvent.setup();
    renderShell();

    await user.click(
      await screen.findByRole("button", { name: "Notifications" }),
    );
    expect(screen.getByText("No notifications yet.")).toBeInTheDocument();
  });

  it("exposes a skip link to main content", async () => {
    renderShell();

    const skip = await screen.findByRole("link", {
      name: "Skip to main content",
    });
    expect(skip).toHaveAttribute("href", "#main-content");
    expect(document.getElementById("main-content")).toBeTruthy();
  });

  it("closes notifications and profile menu on Escape", async () => {
    const user = userEvent.setup();
    renderShell();

    await user.click(
      await screen.findByRole("button", { name: "Notifications" }),
    );
    expect(screen.getByText("No notifications yet.")).toBeInTheDocument();
    await user.keyboard("{Escape}");
    expect(screen.queryByText("No notifications yet.")).not.toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Open profile menu" }));
    expect(
      screen.getByRole("menuitem", { name: "Logout" }),
    ).toBeInTheDocument();
    await user.keyboard("{Escape}");
    expect(
      screen.queryByRole("menuitem", { name: "Logout" }),
    ).not.toBeInTheDocument();
  });
});
