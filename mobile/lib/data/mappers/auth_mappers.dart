import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/farm_settings.dart';
import '../../domain/entities/owner_profile.dart';

OwnerProfile mapOwnerProfile(Map<String, dynamic> json) {
  return OwnerProfile(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    profileImageUrl: json['profile_image_url'] as String,
    updatedAt: json['updated_at'] as String,
  );
}

FarmSettings mapFarmSettings(Map<String, dynamic> json) {
  return FarmSettings(
    id: json['id'] as String,
    ownerId: json['owner_id'] as String,
    currencyCode: json['currency_code'] as String,
    updatedAt: json['updated_at'] as String,
  );
}

AuthTokens mapTokens(Map<String, dynamic> json) {
  return AuthTokens(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    expiresIn: json['expires_in'] as int,
  );
}
