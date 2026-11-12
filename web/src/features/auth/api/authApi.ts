import { apiRequest } from "../../../shared/api/client";
import type {
  FarmSettings,
  OwnerProfile,
  TokenResponse,
} from "../../../shared/api/types";

export type SignUpInput = {
  fullName: string;
  email: string;
  phone: string;
  address: string;
  latitude: number;
  longitude: number;
  password: string;
  confirmPassword: string;
  profileImage: File;
};

export async function signUp(input: SignUpInput): Promise<OwnerProfile> {
  const form = new FormData();
  form.set("full_name", input.fullName);
  form.set("email", input.email);
  form.set("phone", input.phone);
  form.set("address", input.address);
  form.set("latitude", String(input.latitude));
  form.set("longitude", String(input.longitude));
  form.set("password", input.password);
  form.set("confirm_password", input.confirmPassword);
  form.set("profile_image", input.profileImage);

  return apiRequest<OwnerProfile>("/api/v1/auth/signup", {
    method: "POST",
    body: form,
    formData: true,
    auth: false,
  });
}

export async function signIn(
  email: string,
  password: string,
): Promise<TokenResponse> {
  return apiRequest<TokenResponse>("/api/v1/auth/signin", {
    method: "POST",
    body: JSON.stringify({ email, password }),
    auth: false,
  });
}

export async function signOut(refreshToken?: string | null): Promise<void> {
  await apiRequest<void>("/api/v1/auth/signout", {
    method: "POST",
    body: JSON.stringify({ refresh_token: refreshToken ?? null }),
  });
}

export async function getProfile(): Promise<OwnerProfile> {
  return apiRequest<OwnerProfile>("/api/v1/me");
}

export async function updateProfile(fields: {
  fullName?: string;
  email?: string;
  phone?: string;
  address?: string;
  latitude?: number;
  longitude?: number;
  profileImage?: File | null;
}): Promise<OwnerProfile> {
  const form = new FormData();
  if (fields.fullName !== undefined) form.set("full_name", fields.fullName);
  if (fields.email !== undefined) form.set("email", fields.email);
  if (fields.phone !== undefined) form.set("phone", fields.phone);
  if (fields.address !== undefined) form.set("address", fields.address);
  if (fields.latitude !== undefined)
    form.set("latitude", String(fields.latitude));
  if (fields.longitude !== undefined)
    form.set("longitude", String(fields.longitude));
  if (fields.profileImage) form.set("profile_image", fields.profileImage);

  return apiRequest<OwnerProfile>("/api/v1/me", {
    method: "PATCH",
    body: form,
    formData: true,
  });
}

export async function getFarmSettings(): Promise<FarmSettings> {
  return apiRequest<FarmSettings>("/api/v1/farm-settings");
}

export async function updateFarmSettings(
  currencyCode: string,
): Promise<FarmSettings> {
  return apiRequest<FarmSettings>("/api/v1/farm-settings", {
    method: "PATCH",
    body: JSON.stringify({ currency_code: currencyCode }),
  });
}
