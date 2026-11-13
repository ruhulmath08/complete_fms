/** Parse API decimal strings (or numbers) into a finite number, defaulting to 0. */
export function toChartNumber(value: string | number | null | undefined): number {
  const n = typeof value === "number" ? value : Number(value);
  return Number.isFinite(n) ? n : 0;
}
