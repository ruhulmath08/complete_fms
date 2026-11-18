import 'package:mobile/domain/entities/auth/auth_tokens.dart';
import 'package:mobile/domain/entities/auth/farm_settings.dart';
import 'package:mobile/domain/entities/auth/owner_profile.dart';
import 'package:mobile/domain/entities/auth/sign_up_params.dart';

abstract class AuthRepository {
  Future<bool> get isSignedIn;
  Future<OwnerProfile> signUp(SignUpParams params);
  Future<AuthTokens> signIn({required String email, required String password});
  Future<void> signOut();
  Future<OwnerProfile> getProfile();
  Future<OwnerProfile> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? profileImagePath,
  });
  Future<FarmSettings> getFarmSettings();
  Future<FarmSettings> updateFarmSettings(String currencyCode);
  Future<List<int>> getProfileImageBytes();
}
