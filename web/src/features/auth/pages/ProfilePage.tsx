import { useState, type FormEvent } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { getProfile, updateProfile } from "../api/authApi";
import { useProfileImageUrl } from "../hooks/useProfileImageUrl";
import type { OwnerProfile } from "../../../shared/api/types";
import { ApiError, getErrorMessage } from "../../../shared/api/errors";
import { ErrorBanner } from "../../../shared/ui/ErrorBanner";

function ProfileForm({ profile }: { profile: OwnerProfile }) {
  const queryClient = useQueryClient();
  const imageUrl = useProfileImageUrl(profile.updated_at);
  const [fullName, setFullName] = useState(profile.full_name);
  const [email, setEmail] = useState(profile.email);
  const [phone, setPhone] = useState(profile.phone);
  const [address, setAddress] = useState(profile.address);
  const [latitude, setLatitude] = useState(String(profile.latitude));
  const [longitude, setLongitude] = useState(String(profile.longitude));
  const [profileImage, setProfileImage] = useState<File | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  const mutation = useMutation({
    mutationFn: updateProfile,
    onSuccess: async () => {
      setSaved(true);
      setProfileImage(null);
      await queryClient.invalidateQueries({ queryKey: ["profile"] });
    },
    onError: (err) => {
      setSaved(false);
      if (err instanceof ApiError) setError(err.message);
      else setError(getErrorMessage(err));
    },
  });

  function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    setSaved(false);
    mutation.mutate({
      fullName,
      email,
      phone,
      address,
      latitude: Number(latitude),
      longitude: Number(longitude),
      profileImage,
    });
  }

  return (
    <div className="panel panel-wide" style={{ margin: "0 auto" }}>
      <h1>Profile</h1>
      <p className="lede">
        Update your owner profile. Changes save to the shared API.
      </p>
      <ErrorBanner message={error} />
      {saved ? <p className="muted">Profile saved.</p> : null}
      {imageUrl ? (
        <img className="profile-preview" src={imageUrl} alt="Current profile" />
      ) : null}
      <form
        className="form-stack"
        onSubmit={onSubmit}
        style={{ marginTop: "1rem" }}
      >
        <div className="field">
          <label htmlFor="full_name">Full name</label>
          <input
            id="full_name"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            required
          />
        </div>
        <div className="row-2">
          <div className="field">
            <label htmlFor="email">Email</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="field">
            <label htmlFor="phone">Phone</label>
            <input
              id="phone"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              required
            />
          </div>
        </div>
        <div className="field">
          <label htmlFor="address">Address</label>
          <input
            id="address"
            value={address}
            onChange={(e) => setAddress(e.target.value)}
            required
          />
        </div>
        <div className="row-2">
          <div className="field">
            <label htmlFor="latitude">Latitude</label>
            <input
              id="latitude"
              type="number"
              step="any"
              value={latitude}
              onChange={(e) => setLatitude(e.target.value)}
              required
            />
          </div>
          <div className="field">
            <label htmlFor="longitude">Longitude</label>
            <input
              id="longitude"
              type="number"
              step="any"
              value={longitude}
              onChange={(e) => setLongitude(e.target.value)}
              required
            />
          </div>
        </div>
        <div className="field">
          <label htmlFor="profile_image">Replace profile image</label>
          <input
            id="profile_image"
            type="file"
            accept="image/png,image/jpeg,image/webp"
            onChange={(e) => setProfileImage(e.target.files?.[0] ?? null)}
          />
        </div>
        <button
          className="btn btn-primary"
          type="submit"
          disabled={mutation.isPending}
        >
          {mutation.isPending ? "Saving…" : "Save profile"}
        </button>
      </form>
    </div>
  );
}

export function ProfilePage() {
  const profileQuery = useQuery({ queryKey: ["profile"], queryFn: getProfile });

  if (profileQuery.isLoading) return <p className="muted">Loading profile…</p>;
  if (profileQuery.isError) {
    return <ErrorBanner message={getErrorMessage(profileQuery.error)} />;
  }
  if (!profileQuery.data) return null;

  return (
    <ProfileForm
      key={profileQuery.data.updated_at}
      profile={profileQuery.data}
    />
  );
}
