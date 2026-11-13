import { describe, expect, it } from "vitest";
import {
  clampToToday,
  grainForRange,
  normalizeRange,
  periodRange,
  weekStartIso,
} from "./dates";

// Friday 13 Nov 2026
const now = new Date(2026, 10, 13, 12, 0, 0);

describe("dates", () => {
  it("starts the week on Monday", () => {
    expect(weekStartIso(now)).toBe("2026-11-09");
    expect(weekStartIso(new Date(2026, 10, 15))).toBe("2026-11-09"); // Sunday
    expect(weekStartIso(new Date(2026, 10, 9))).toBe("2026-11-09"); // Monday
  });

  it("builds period ranges ending today", () => {
    expect(periodRange("day", now)).toEqual({
      from: "2026-11-13",
      to: "2026-11-13",
      grain: "day",
    });
    expect(periodRange("week", now)).toEqual({
      from: "2026-11-09",
      to: "2026-11-13",
      grain: "day",
    });
    expect(periodRange("month", now)).toEqual({
      from: "2026-11-01",
      to: "2026-11-13",
      grain: "day",
    });
    expect(periodRange("year", now)).toEqual({
      from: "2026-01-01",
      to: "2026-11-13",
      grain: "month",
    });
  });

  it("clamps future dates to today", () => {
    expect(clampToToday("2026-12-31", now)).toBe("2026-11-13");
    expect(clampToToday("2026-11-01", now)).toBe("2026-11-01");
    expect(normalizeRange("2027-01-01", "2027-02-01", now)).toEqual({
      from: "2026-11-13",
      to: "2026-11-13",
    });
  });

  it("picks grain from range length", () => {
    expect(grainForRange("2026-11-01", "2026-11-30")).toBe("day");
    expect(grainForRange("2026-09-01", "2026-11-13")).toBe("week");
    expect(grainForRange("2026-01-01", "2026-11-13")).toBe("month");
  });
});
