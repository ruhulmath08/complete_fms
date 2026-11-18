import 'package:mobile/data/models/auth/auth_tokens_model.dart';
import 'package:mobile/data/models/auth/farm_settings_model.dart';
import 'package:mobile/data/models/auth/owner_profile_model.dart';
import 'package:mobile/domain/entities/auth/auth_tokens.dart';
import 'package:mobile/domain/entities/auth/farm_settings.dart';
import 'package:mobile/domain/entities/auth/owner_profile.dart';

OwnerProfile mapOwnerProfile(Map<String, dynamic> json) =>
    mapOwnerProfileModel(OwnerProfileModel.fromJson(json));

OwnerProfile mapOwnerProfileModel(OwnerProfileModel model) => OwnerProfile(
      id: model.id,
      fullName: model.fullName,
      email: model.email,
      phone: model.phone,
      address: model.address,
      latitude: model.latitude,
      longitude: model.longitude,
      profileImageUrl: model.profileImageUrl,
      updatedAt: model.updatedAt,
    );

FarmSettings mapFarmSettings(Map<String, dynamic> json) =>
    mapFarmSettingsModel(FarmSettingsModel.fromJson(json));

FarmSettings mapFarmSettingsModel(FarmSettingsModel model) => FarmSettings(
      id: model.id,
      ownerId: model.ownerId,
      currencyCode: model.currencyCode,
      updatedAt: model.updatedAt,
    );

AuthTokens mapTokens(Map<String, dynamic> json) =>
    mapTokensModel(AuthTokensModel.fromJson(json));

AuthTokens mapTokensModel(AuthTokensModel model) => AuthTokens(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
      expiresIn: model.expiresIn,
    );
