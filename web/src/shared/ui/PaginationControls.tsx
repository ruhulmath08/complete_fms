type PaginationControlsProps = {
  total: number;
  limit: number;
  offset: number;
  onOffsetChange: (offset: number) => void;
  label: string;
};

export function PaginationControls({
  total,
  limit,
  offset,
  onOffsetChange,
  label,
}: PaginationControlsProps) {
  const page = Math.floor(offset / limit) + 1;
  const totalPages = Math.max(1, Math.ceil(total / limit));
  const canPrev = offset > 0;
  const canNext = offset + limit < total;

  if (total === 0) return null;

  return (
    <div className="table-pagination" aria-label={`${label} pagination`}>
      <span className="muted">
        Page {page} of {totalPages} · {total} total
      </span>
      <div className="toolbar-actions">
        <button
          type="button"
          className="btn btn-ghost"
          disabled={!canPrev}
          onClick={() => onOffsetChange(Math.max(0, offset - limit))}
        >
          Previous
        </button>
        <button
          type="button"
          className="btn btn-ghost"
          disabled={!canNext}
          onClick={() => onOffsetChange(offset + limit)}
        >
          Next
        </button>
      </div>
    </div>
  );
}
