import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "../auth/useAuth";

export function ProtectedRoute() {
  const { isSignedIn } = useAuth();
  if (!isSignedIn) return <Navigate to="/signin" replace />;
  return <Outlet />;
}
