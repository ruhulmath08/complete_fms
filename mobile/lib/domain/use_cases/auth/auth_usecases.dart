import 'package:mobile/domain/entities/auth/farm_settings_entity.dart';
import 'package:mobile/domain/entities/auth/owner_profile_entity.dart';
import 'package:mobile/domain/entities/auth/sign_up_params_entity.dart';
import 'package:mobile/domain/repositories/auth/auth_repository.dart';
import 'package:mobile/domain/result.dart';

class SignUp {
  SignUp(this._repository);

  final AuthRepository _repository;

  Future<Result<OwnerProfileEntity>> call(SignUpParamsEntity params) =>
      _repository.signUp(params);
}

class SignOut {
  SignOut(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call() => _repository.signOut();
}

class GetProfile {
  GetProfile(this._repository);

  final AuthRepository _repository;

  Future<Result<OwnerProfileEntity>> call() => _repository.getProfile();
}

class UpdateProfile {
  UpdateProfile(this._repository);

  final AuthRepository _repository;

  Future<Result<OwnerProfileEntity>> call({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? profileImagePath,
  }) =>
      _repository.updateProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        profileImagePath: profileImagePath,
      );
}

class GetFarmSettings {
  GetFarmSettings(this._repository);

  final AuthRepository _repository;

  Future<Result<FarmSettingsEntity>> call() => _repository.getFarmSettings();
}

class UpdateFarmSettings {
  UpdateFarmSettings(this._repository);

  final AuthRepository _repository;

  Future<Result<FarmSettingsEntity>> call(String currencyCode) =>
      _repository.updateFarmSettings(currencyCode);
}

class IsSignedIn {
  IsSignedIn(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.isSignedIn;
}
