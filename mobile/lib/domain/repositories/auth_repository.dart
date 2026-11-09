import '../entities/auth_tokens.dart';
import '../entities/farm_settings.dart';
import '../entities/owner_profile.dart';

class SignUpParams {
  SignUpParams({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.password,
    required this.confirmPassword,
    required this.profileImagePath,
  });

  final String fullName;
  final String email;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String password;
  final String confirmPassword;
  final String profileImagePath;
}

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
