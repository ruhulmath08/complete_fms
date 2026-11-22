import 'package:mobile/domain/entities/auth/auth_tokens_entity.dart';
import 'package:mobile/domain/repositories/auth/auth_repository.dart';
import 'package:mobile/domain/result.dart';

class SignInUseCase {
  SignInUseCase({required this.repository});

  final AuthRepository repository;

  Future<Result<AuthTokensEntity>> call({
    required String email,
    required String password,
  }) =>
      repository.signIn(email: email, password: password);
}
