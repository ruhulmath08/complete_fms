export function LoadingState({ message }: { message: string }) {
  return (
    <p className="loading-state" role="status" aria-live="polite">
      {message}
    </p>
  );
}
