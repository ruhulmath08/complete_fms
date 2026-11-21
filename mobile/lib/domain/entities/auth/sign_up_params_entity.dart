class SignUpParamsEntity {
  const SignUpParamsEntity({
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
