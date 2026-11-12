export type ApiErrorBody = {
  code: string;
  message: string;
  details?: Record<string, unknown>;
};

export type TokenResponse = {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
};

export type OwnerProfile = {
  id: string;
  full_name: string;
  email: string;
  phone: string;
  address: string;
  latitude: number;
  longitude: number;
  profile_image_url: string;
  created_at: string;
  updated_at: string;
};

export type FarmSettings = {
  id: string;
  owner_id: string;
  currency_code: string;
  created_at: string;
  updated_at: string;
};
