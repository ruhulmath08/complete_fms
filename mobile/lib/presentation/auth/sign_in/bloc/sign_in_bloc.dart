import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/domain/use_cases/auth/sign_in/sign_in_use_case.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc({required this.signInUseCase})
    : super(
        const SignInState(
          initial: SignInStateEnum.initial,
          userName: '',
          password: '',
          errorMessage: '',
        ),
      ) {
    on<SignInUsernameChange>(_onUsernameChange);
    on<SignInPasswordChange>(_onPasswordChange);
    on<SignInSubmitted>(_onSubmitted);
  }

  final SignInUseCase signInUseCase;

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
    emit(state.copyWith(initial: SignInStateEnum.loading));
    final email = state.userName.trim();
    final password = state.password.trim();

    if (email.isEmpty || password.isEmpty) {
      emit(
        state.copyWith(
          initial: SignInStateEnum.failed,
          errorMessage: 'Please fill in all fields.',
        ),
      );
      return;
    }

    final result = await signInUseCase(email: email, password: password);
    result.when(
      success: (_) => emit(state.copyWith(initial: SignInStateEnum.success)),
      failure: (failure) => emit(
        state.copyWith(
          initial: SignInStateEnum.failed,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
