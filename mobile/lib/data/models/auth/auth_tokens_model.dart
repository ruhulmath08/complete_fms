import 'package:mobile/data/models/common/json_parsers.dart';

class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'bearer',
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      AuthTokensModel(
        accessToken: requireString(json['access_token'], 'access_token'),
        refreshToken: requireString(json['refresh_token'], 'refresh_token'),
        expiresIn: requireInt(json['expires_in'], 'expires_in'),
        tokenType: optionalString(json['token_type']) ?? 'bearer',
      );

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
        'token_type': tokenType,
      };
}
