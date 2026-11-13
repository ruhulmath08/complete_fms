import type { ReactNode } from "react";

export type ChartPoint = { x: string; y: number };

export type ChartSeries = {
  key: string;
  label: string;
  color: string;
  points: ChartPoint[];
};

type SeriesChartProps = {
  title?: string;
  ariaLabel: string;
  series: ChartSeries[];
  height?: number;
  emptyMessage?: string;
};

const WIDTH = 640;
const PAD = { top: 12, right: 16, bottom: 28, left: 52 };

function formatTick(value: number): string {
  if (Number.isInteger(value)) return String(value);
  return value.toFixed(2);
}

/**
 * Simple dependency-free multi-series SVG line chart.
 * X positions are shared across series using the sorted union of x labels.
 */
export function SeriesChart({
  title,
  ariaLabel,
  series,
  height = 220,
  emptyMessage = "No data for this period.",
}: SeriesChartProps) {
  const xs = Array.from(
    new Set(series.flatMap((s) => s.points.map((p) => p.x))),
  ).sort();

  const wrapper = (body: ReactNode) => (
    <figure className="series-chart">
      {title ? <figcaption className="series-chart__title">{title}</figcaption> : null}
      {body}
    </figure>
  );

  if (xs.length === 0) {
    return wrapper(<p className="muted">{emptyMessage}</p>);
  }

  const allValues = series.flatMap((s) => s.points.map((p) => p.y));
  const min = Math.min(0, ...allValues);
  let max = Math.max(0, ...allValues);
  if (min === max) max = min + 1;
  const innerW = WIDTH - PAD.left - PAD.right;
  const innerH = height - PAD.top - PAD.bottom;

  const xPos = (x: string) => {
    const i = xs.indexOf(x);
    if (xs.length === 1) return PAD.left + innerW / 2;
    return PAD.left + (i / (xs.length - 1)) * innerW;
  };
  const yPos = (y: number) => PAD.top + (1 - (y - min) / (max - min)) * innerH;

  const ticks = [min, min + (max - min) / 2, max];

  return wrapper(
    <>
      <svg
        className="series-chart__svg"
        viewBox={`0 0 ${WIDTH} ${height}`}
        role="img"
        aria-label={ariaLabel}
        preserveAspectRatio="xMidYMid meet"
      >
        {ticks.map((t) => (
          <g key={t}>
            <line
              x1={PAD.left}
              x2={WIDTH - PAD.right}
              y1={yPos(t)}
              y2={yPos(t)}
              stroke="#d5ddd4"
              strokeWidth={1}
            />
            <text
              x={PAD.left - 6}
              y={yPos(t) + 4}
              textAnchor="end"
              fontSize={11}
              fill="#5b6b5e"
            >
              {formatTick(t)}
            </text>
          </g>
        ))}
        <text
          x={PAD.left}
          y={height - 8}
          textAnchor="start"
          fontSize={11}
          fill="#5b6b5e"
        >
          {xs[0]}
        </text>
        {xs.length > 1 ? (
          <text
            x={WIDTH - PAD.right}
            y={height - 8}
            textAnchor="end"
            fontSize={11}
            fill="#5b6b5e"
          >
            {xs[xs.length - 1]}
          </text>
        ) : null}
        {series.map((s) => {
          const pts = [...s.points].sort((a, b) => a.x.localeCompare(b.x));
          if (pts.length === 0) return null;
          return (
            <g key={s.key} data-series={s.key}>
              <polyline
                fill="none"
                stroke={s.color}
                strokeWidth={2}
                points={pts.map((p) => `${xPos(p.x)},${yPos(p.y)}`).join(" ")}
              />
              {pts.map((p) => (
                <circle
                  key={p.x}
                  cx={xPos(p.x)}
                  cy={yPos(p.y)}
                  r={3}
                  fill={s.color}
                >
                  <title>{`${s.label} ${p.x}: ${p.y}`}</title>
                </circle>
              ))}
            </g>
          );
        })}
      </svg>
      <ul className="series-chart__legend" aria-label="Legend">
        {series.map((s) => (
          <li key={s.key}>
            <span
              className="series-chart__swatch"
              style={{ background: s.color }}
              aria-hidden="true"
            />
            {s.label}
          </li>
        ))}
      </ul>
    </>,
  );
}
