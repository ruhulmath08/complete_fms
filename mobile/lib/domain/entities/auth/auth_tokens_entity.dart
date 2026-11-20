import 'package:equatable/equatable.dart';

class AuthTokensEntity extends Equatable {
  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
}
