export type SeriesGrain = "day" | "week" | "month";
export type PeriodKind = "day" | "week" | "month" | "year";

function pad(n: number): string {
  return String(n).padStart(2, "0");
}

/** Local calendar date as YYYY-MM-DD (avoids UTC drift from toISOString). */
export function toIsoDate(date: Date): string {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

export function todayIso(now: Date = new Date()): string {
  return toIsoDate(now);
}

function parseIsoDate(value: string): Date {
  const [y, m, d] = value.split("-").map(Number);
  return new Date(y, (m ?? 1) - 1, d ?? 1);
}

/** Monday of the ISO week containing `now`. */
export function weekStartIso(now: Date = new Date()): string {
  const day = (now.getDay() + 6) % 7; // Monday = 0
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate() - day);
  return toIsoDate(start);
}

export function monthStartIso(now: Date = new Date()): string {
  return toIsoDate(new Date(now.getFullYear(), now.getMonth(), 1));
}

export function yearStartIso(now: Date = new Date()): string {
  return toIsoDate(new Date(now.getFullYear(), 0, 1));
}

/** Clamp an ISO date so it is never later than today. */
export function clampToToday(value: string, now: Date = new Date()): string {
  const today = todayIso(now);
  return value > today ? today : value;
}

/** Choose a chart grain that keeps the number of buckets readable. */
export function grainForRange(from: string, to: string): SeriesGrain {
  const days =
    Math.round(
      (parseIsoDate(to).getTime() - parseIsoDate(from).getTime()) / 86_400_000,
    ) + 1;
  if (days <= 31) return "day";
  if (days <= 120) return "week";
  return "month";
}

export type PeriodRange = { from: string; to: string; grain: SeriesGrain };

/** Date range for a named period ending today (week starts Monday). */
export function periodRange(
  period: PeriodKind,
  now: Date = new Date(),
): PeriodRange {
  const to = todayIso(now);
  switch (period) {
    case "day":
      return { from: to, to, grain: "day" };
    case "week":
      return { from: weekStartIso(now), to, grain: "day" };
    case "month":
      return { from: monthStartIso(now), to, grain: "day" };
    case "year":
      return { from: yearStartIso(now), to, grain: "month" };
  }
}

/** Normalise a user-entered range: clamp `to` <= today and keep from <= to. */
export function normalizeRange(
  from: string,
  to: string,
  now: Date = new Date(),
): { from: string; to: string } {
  const clampedTo = clampToToday(to, now);
  const clampedFrom = clampToToday(from, now);
  return {
    from: clampedFrom > clampedTo ? clampedTo : clampedFrom,
    to: clampedTo,
  };
}
