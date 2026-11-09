import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';

class SessionCubit extends Cubit<bool> {
  SessionCubit(this._isSignedIn, this._signOut) : super(false);

  final IsSignedIn _isSignedIn;
  final SignOut _signOut;

  Future<void> bootstrap() async {
    emit(await _isSignedIn());
  }

  void markSignedIn() => emit(true);

  Future<void> signOut() async {
    await _signOut();
    emit(false);
  }
}
