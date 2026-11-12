import 'package:mobile/domain/sign_in/entities/sign_in_entity.dart';
import 'package:mobile/domain/sign_in/repository/sign_in_repository.dart';

class SignInUseCase {
  SignInUseCase({required this.repository});

  final SignInRepository repository;

  Future<SignInEntity> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}
