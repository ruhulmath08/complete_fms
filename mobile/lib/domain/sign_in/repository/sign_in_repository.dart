import '../entities/sign_in_entity.dart';

abstract class SignInRepository {
  Future<SignInEntity> signIn({
    required String email,
    required String password,
  });
}
