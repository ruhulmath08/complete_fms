import { useState, type FormEvent } from "react";
import { Link, Navigate, useNavigate } from "react-router-dom";
import { signUp } from "../api/authApi";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { useAuth } from "../../../shared/auth/useAuth";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";

export function SignUpPage() {
  const { isSignedIn } = useAuth();
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  if (isSignedIn) return <Navigate to="/profile" replace />;

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSubmitting(true);
    const form = new FormData(event.currentTarget);
    const profileImage = form.get("profile_image");
    if (!(profileImage instanceof File) || profileImage.size === 0) {
      setError("Profile image is required.");
      setSubmitting(false);
      return;
    }

    try {
      await signUp({
        fullName: String(form.get("full_name") ?? ""),
        email: String(form.get("email") ?? ""),
        phone: String(form.get("phone") ?? ""),
        address: String(form.get("address") ?? ""),
        latitude: Number(form.get("latitude")),
        longitude: Number(form.get("longitude")),
        password: String(form.get("password") ?? ""),
        confirmPassword: String(form.get("confirm_password") ?? ""),
        profileImage,
      });
      navigate("/signin", { state: { signedUp: true } });
    } catch (err) {
      if (err instanceof ApiError) {
        setError(err.message);
      } else {
        setError(getErrorMessage(err));
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="auth-layout">
      <div className="panel panel-wide">
        <p className="brand">Farm Manager</p>
        <h1>Create account</h1>
        <p className="lede">
          Register as the farm owner. You will sign in after signup.
        </p>
        <ErrorBanner message={error} />
        <form className="form-stack" onSubmit={onSubmit}>
          <div className="field">
            <label htmlFor="full_name">Full name</label>
            <input id="full_name" name="full_name" required />
          </div>
          <div className="row-2">
            <div className="field">
              <label htmlFor="email">Email</label>
              <input id="email" name="email" type="email" required />
            </div>
            <div className="field">
              <label htmlFor="phone">Phone</label>
              <input id="phone" name="phone" required />
            </div>
          </div>
          <div className="field">
            <label htmlFor="address">Address</label>
            <input id="address" name="address" required />
          </div>
          <div className="row-2">
            <div className="field">
              <label htmlFor="latitude">Latitude</label>
              <input
                id="latitude"
                name="latitude"
                type="number"
                step="any"
                required
              />
            </div>
            <div className="field">
              <label htmlFor="longitude">Longitude</label>
              <input
                id="longitude"
                name="longitude"
                type="number"
                step="any"
                required
              />
            </div>
          </div>
          <div className="field">
            <label htmlFor="profile_image">Profile image</label>
            <input
              id="profile_image"
              name="profile_image"
              type="file"
              accept="image/png,image/jpeg,image/webp"
              required
            />
          </div>
          <div className="row-2">
            <div className="field">
              <label htmlFor="password">Password</label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="new-password"
                required
              />
            </div>
            <div className="field">
              <label htmlFor="confirm_password">Confirm password</label>
              <input
                id="confirm_password"
                name="confirm_password"
                type="password"
                autoComplete="new-password"
                required
              />
            </div>
          </div>
          <button
            className="btn btn-primary"
            type="submit"
            disabled={submitting}
          >
            {submitting ? "Creating…" : "Create account"}
          </button>
        </form>
        <p className="muted" style={{ marginTop: "1.25rem" }}>
          Already registered? <Link to="/signin">Sign in</Link>
        </p>
      </div>
    </div>
  );
}
