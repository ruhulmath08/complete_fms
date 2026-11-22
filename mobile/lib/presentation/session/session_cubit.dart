import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/domain/use_cases/auth/auth_usecases.dart';
import 'package:mobile/domain/use_cases/auth/sign_in/sign_out_use_case.dart';

class SessionCubit extends Cubit<bool> {
  SessionCubit(this._isSignedIn, this.signOutUseCase) : super(false);

  final IsSignedIn _isSignedIn;
  final SignOutUseCase signOutUseCase;

  Future<void> bootstrap() async {
    emit(await _isSignedIn());
  }

  void markSignedIn() => emit(true);

  Future<void> signOut() async {
    await signOutUseCase(); // Result ignored: always clear local session state
    emit(false);
  }
}
