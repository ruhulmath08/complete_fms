import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { CowForm } from "./CowForm";

describe("CowForm", () => {
  it("shows purchase fields only when acquired by purchase", async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();

    render(<CowForm submitLabel="Save" onSubmit={onSubmit} />);

    expect(screen.queryByLabelText("Purchase date")).not.toBeInTheDocument();
    expect(screen.queryByLabelText("Purchase price")).not.toBeInTheDocument();

    await user.selectOptions(screen.getByLabelText("Acquired by"), "purchased");

    expect(screen.getByLabelText("Purchase date")).toBeInTheDocument();
    expect(screen.getByLabelText("Purchase price")).toBeInTheDocument();
  });

  it("requires name and breed and omits client tag on create", async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();

    render(<CowForm submitLabel="Save" onSubmit={onSubmit} />);

    expect(screen.queryByLabelText("Tag number")).not.toBeInTheDocument();
    expect(screen.getByLabelText("Weight (kg)")).toBeInTheDocument();
    expect(screen.getByLabelText("Cow image")).toBeInTheDocument();

    await user.type(screen.getByLabelText("Name"), "Bella");
    await user.type(screen.getByLabelText("Breed"), "Holstein");
    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(onSubmit).toHaveBeenCalledWith(
      expect.objectContaining({
        name: "Bella",
        breed: "Holstein",
        acquired_by: "born_on_farm",
        purchase_date: null,
        purchase_price: null,
      }),
      null,
    );
    expect(onSubmit.mock.calls[0][0]).not.toHaveProperty("tag_number");
  });
});
