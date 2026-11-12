import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/auth_usecases.dart';
import '../../../../infrastructure/di/injection.dart';

part 'sign_in_event.dart';

part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc()
    : super(
        SignInState(
          initial: SignInStateEnum.initial,
          userName: '',
          password: '',
        ),
      ) {
    on<SignInUsernameChange>(_onUsernameChange);
    on<SignInPasswordChange>(_onPasswordChange);
    on<SignInSubmitted>(_onSubmitted);
  }

  void _onUsernameChange(
    SignInUsernameChange event,
    Emitter<SignInState> emit,
  ) {
    emit(
      state.copyWith(
        userName: event.username,
        initial: SignInStateEnum.initial,
      ),
    );
  }

  void _onPasswordChange(
    SignInPasswordChange event,
    Emitter<SignInState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.password,
        initial: SignInStateEnum.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    final email = state.userName.trim();
    final password = state.password.trim();

    if (email.isEmpty || password.isEmpty) {
      emit(state.copyWith(initial: SignInStateEnum.failed));
      return;
    }

    emit(state.copyWith(initial: SignInStateEnum.loading));

    try {
      await getIt<SignIn>()(email: email, password: password);
      emit(state.copyWith(initial: SignInStateEnum.success));
    } catch (_) {
      emit(state.copyWith(initial: SignInStateEnum.failed));
    }
  }
}
