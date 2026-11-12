import 'package:mobile/data/sign_in/model/sign_in_model.dart';
import 'package:mobile/domain/sign_in/entities/sign_in_entity.dart';

class SignInMapper {
  static SignInEntity mapModelToEntity(SignInModel model) {
    return SignInEntity(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
      tokenType: model.tokenType,
      expiresIn: model.expiresIn,
    );
  }
}
