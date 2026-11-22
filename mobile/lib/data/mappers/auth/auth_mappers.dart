import 'package:mobile/data/models/auth/auth_tokens_model.dart';
import 'package:mobile/data/models/auth/farm_settings_model.dart';
import 'package:mobile/data/models/auth/owner_profile_model.dart';
import 'package:mobile/domain/entities/auth/auth_tokens_entity.dart';
import 'package:mobile/domain/entities/auth/farm_settings_entity.dart';
import 'package:mobile/domain/entities/auth/owner_profile_entity.dart';

OwnerProfileEntity mapOwnerProfile(Map<String, dynamic> json) =>
    mapOwnerProfileModel(OwnerProfileModel.fromJson(json));

OwnerProfileEntity mapOwnerProfileModel(OwnerProfileModel model) => OwnerProfileEntity(
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

FarmSettingsEntity mapFarmSettings(Map<String, dynamic> json) =>
    mapFarmSettingsModel(FarmSettingsModel.fromJson(json));

FarmSettingsEntity mapFarmSettingsModel(FarmSettingsModel model) => FarmSettingsEntity(
      id: model.id,
      ownerId: model.ownerId,
      currencyCode: model.currencyCode,
      updatedAt: model.updatedAt,
    );

AuthTokensEntity mapTokens(Map<String, dynamic> json) =>
    mapTokensModel(AuthTokensModel.fromJson(json));

AuthTokensEntity mapTokensModel(AuthTokensModel model) => AuthTokensEntity(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
      expiresIn: model.expiresIn,
    );
