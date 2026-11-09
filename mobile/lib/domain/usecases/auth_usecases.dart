import '../entities/auth_tokens.dart';
import '../entities/farm_settings.dart';
import '../entities/owner_profile.dart';
import '../repositories/auth_repository.dart';

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
