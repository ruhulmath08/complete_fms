import 'package:mobile/domain/entities/auth/auth_tokens_entity.dart';
import 'package:mobile/domain/entities/auth/farm_settings_entity.dart';
import 'package:mobile/domain/entities/auth/owner_profile_entity.dart';
import 'package:mobile/domain/entities/auth/sign_up_params_entity.dart';
import 'package:mobile/domain/result.dart';

abstract class AuthRepository {
  Future<bool> get isSignedIn;

  Future<Result<OwnerProfileEntity>> signUp(SignUpParamsEntity params);

  Future<Result<AuthTokensEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Result<Unit>> signOut();

  Future<Result<OwnerProfileEntity>> getProfile();

  Future<Result<OwnerProfileEntity>> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? profileImagePath,
  });

  Future<Result<FarmSettingsEntity>> getFarmSettings();

  Future<Result<FarmSettingsEntity>> updateFarmSettings(String currencyCode);

  Future<Result<List<int>>> getProfileImageBytes();
}
