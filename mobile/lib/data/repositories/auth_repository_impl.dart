import 'package:dio/dio.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/farm_settings.dart';
import '../../domain/entities/owner_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';
import '../datasources/token_store.dart';
import '../mappers/auth_mappers.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._tokenStore);

  final AuthApi _api;
  final TokenStore _tokenStore;

  @override
  Future<bool> get isSignedIn => _tokenStore.hasAccess();

  @override
  Future<OwnerProfile> signUp(SignUpParams params) async {
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
    final json = await _api.signUp(form);
    return mapOwnerProfile(json);
  }

  @override
  Future<AuthTokens> signIn({
    required String email,
    required String password,
  }) async {
    final json = await _api.signIn(email, password);
    final tokens = mapTokens(json);
    await _tokenStore.save(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
    );
    return tokens;
  }

  @override
  Future<void> signOut() async {
    final refresh = await _tokenStore.readRefresh();
    try {
      await _api.signOut(refresh);
    } finally {
      await _tokenStore.clear();
    }
  }

  @override
  Future<OwnerProfile> getProfile() async {
    return mapOwnerProfile(await _api.getMe());
  }

  @override
  Future<OwnerProfile> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? profileImagePath,
  }) async {
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
    final json = await _api.patchMe(FormData.fromMap(map));
    return mapOwnerProfile(json);
  }

  @override
  Future<FarmSettings> getFarmSettings() async {
    return mapFarmSettings(await _api.getFarmSettings());
  }

  @override
  Future<FarmSettings> updateFarmSettings(String currencyCode) async {
    return mapFarmSettings(await _api.patchFarmSettings(currencyCode));
  }

  @override
  Future<List<int>> getProfileImageBytes() => _api.getProfileImageBytes();
}
