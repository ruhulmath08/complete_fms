import 'package:dio/dio.dart';
import 'package:mobile/data/datasources/auth/auth_local_datasource.dart';
import 'package:mobile/data/datasources/auth/auth_remote_datasource.dart';
import 'package:mobile/data/mappers/auth/auth_mappers.dart';
import 'package:mobile/data/models/auth/auth_tokens_model.dart';
import 'package:mobile/data/models/auth/farm_settings_model.dart';
import 'package:mobile/data/models/auth/owner_profile_model.dart';
import 'package:mobile/data/network/safe_api_call.dart';
import 'package:mobile/domain/entities/auth/auth_tokens_entity.dart';
import 'package:mobile/domain/entities/auth/farm_settings_entity.dart';
import 'package:mobile/domain/entities/auth/owner_profile_entity.dart';
import 'package:mobile/domain/entities/auth/sign_up_params_entity.dart';
import 'package:mobile/domain/repositories/auth/auth_repository.dart';
import 'package:mobile/domain/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  @override
  Future<bool> get isSignedIn => _local.hasAccessToken();

  @override
  Future<Result<OwnerProfileEntity>> signUp(SignUpParamsEntity params) => safeApiCall(() async {
        final form = FormData.fromMap({
          'full_name': params.fullName,
          'email': params.email,
          'phone': params.phone,
          'address': params.address,
          'latitude': params.latitude,
          'longitude': params.longitude,
          'password': params.password,
          'confirm_password': params.confirmPassword,
          'profile_image': await MultipartFile.fromFile(
            params.profileImagePath,
            filename: params.profileImagePath.split('/').last,
          ),
        });
        final model = OwnerProfileModel.fromJson(await _remote.signUp(form));
        return mapOwnerProfileModel(model);
      });

  @override
  Future<Result<AuthTokensEntity>> signIn({
    required String email,
    required String password,
  }) =>
      safeApiCall(() async {
        final model = AuthTokensModel.fromJson(
          await _remote.signIn(email, password),
        );
        final tokens = mapTokensModel(model);
        await _local.saveTokens(
          access: tokens.accessToken,
          refresh: tokens.refreshToken,
        );
        return tokens;
      });

  @override
  Future<Result<Unit>> signOut() => safeApiCall(() async {
        final refresh = await _local.readRefreshToken();
        try {
          await _remote.signOut(refresh);
        } finally {
          await _local.clearTokens();
        }
        return Unit.value;
      });

  @override
  Future<Result<OwnerProfileEntity>> getProfile() => safeApiCall(() async {
        final model = OwnerProfileModel.fromJson(await _remote.getMe());
        return mapOwnerProfileModel(model);
      });

  @override
  Future<Result<OwnerProfileEntity>> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? profileImagePath,
  }) =>
      safeApiCall(() async {
        final map = <String, dynamic>{};
        if (fullName != null) map['full_name'] = fullName;
        if (email != null) map['email'] = email;
        if (phone != null) map['phone'] = phone;
        if (address != null) map['address'] = address;
        if (latitude != null) map['latitude'] = latitude;
        if (longitude != null) map['longitude'] = longitude;
        if (profileImagePath != null) {
          map['profile_image'] = await MultipartFile.fromFile(
            profileImagePath,
            filename: profileImagePath.split('/').last,
          );
        }
        final model = OwnerProfileModel.fromJson(
          await _remote.patchMe(FormData.fromMap(map)),
        );
        return mapOwnerProfileModel(model);
      });

  @override
  Future<Result<FarmSettingsEntity>> getFarmSettings() => safeApiCall(() async {
        final model = FarmSettingsModel.fromJson(await _remote.getFarmSettings());
        return mapFarmSettingsModel(model);
      });

  @override
  Future<Result<FarmSettingsEntity>> updateFarmSettings(String currencyCode) =>
      safeApiCall(() async {
        final model = FarmSettingsModel.fromJson(
          await _remote.patchFarmSettings(currencyCode),
        );
        return mapFarmSettingsModel(model);
      });

  @override
  Future<Result<List<int>>> getProfileImageBytes() =>
      safeApiCall(_remote.getProfileImageBytes);
}
