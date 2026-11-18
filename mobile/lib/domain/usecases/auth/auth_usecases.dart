import 'package:mobile/domain/entities/auth/sign_up_params.dart';
import 'package:mobile/domain/repositories/auth/auth_repository.dart';
import 'package:mobile/domain/entities/auth/auth_tokens.dart';
import 'package:mobile/domain/entities/auth/farm_settings.dart';
import 'package:mobile/domain/entities/auth/owner_profile.dart';

class SignUp {
  SignUp(this._repository);
  final AuthRepository _repository;
  Future<OwnerProfile> call(SignUpParams params) => _repository.signUp(params);
}

class SignIn {
  SignIn(this._repository);
  final AuthRepository _repository;
  Future<AuthTokens> call({required String email, required String password}) =>
      _repository.signIn(email: email, password: password);
}

class SignOut {
  SignOut(this._repository);
  final AuthRepository _repository;
  Future<void> call() => _repository.signOut();
}

class GetProfile {
  GetProfile(this._repository);
  final AuthRepository _repository;
  Future<OwnerProfile> call() => _repository.getProfile();
}

class UpdateProfile {
  UpdateProfile(this._repository);
  final AuthRepository _repository;
  Future<OwnerProfile> call({
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
  Future<FarmSettings> call() => _repository.getFarmSettings();
}

class UpdateFarmSettings {
  UpdateFarmSettings(this._repository);
  final AuthRepository _repository;
  Future<FarmSettings> call(String currencyCode) =>
      _repository.updateFarmSettings(currencyCode);
}

class IsSignedIn {
  IsSignedIn(this._repository);
  final AuthRepository _repository;
  Future<bool> call() => _repository.isSignedIn;
}
