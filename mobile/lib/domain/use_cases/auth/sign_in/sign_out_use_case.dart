import 'package:mobile/domain/repositories/auth/auth_repository.dart';
import 'package:mobile/domain/result.dart';

class SignOutUseCase {
  SignOutUseCase({required this.authRepository});

  final AuthRepository authRepository;

  Future<Result<Unit>> call() => authRepository.signOut();
}
