import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/domain/use_cases/auth/sign_in/sign_in_use_case.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc({required this.signInUseCase})
    : super(
        const SignInState(
          statusEnum: SignInStateEnum.initial,
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
    print('Username changed: ${event.username}');
    emit(
      state.copyWith(
        userName: event.username,
        statusEnum: SignInStateEnum.initial,
      ),
    );
  }

  void _onPasswordChange(
    SignInPasswordChange event,
    Emitter<SignInState> emit,
  ) {
    print('Password changed: ${event.password}');
    emit(
      state.copyWith(
        password: event.password,
        statusEnum: SignInStateEnum.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(state.copyWith(statusEnum: SignInStateEnum.loading));
    final email = state.userName.trim();
    final password = state.password.trim();

    if (email.isEmpty || password.isEmpty) {
      emit(
        state.copyWith(
          statusEnum: SignInStateEnum.failed,
          errorMessage: 'Please fill in all fields.',
        ),
      );
      return;
    }

    final result = await signInUseCase(email: email, password: password);
    result.when(
      success: (_) => emit(state.copyWith(statusEnum: SignInStateEnum.success)),
      failure: (failure) => emit(
        state.copyWith(
          statusEnum: SignInStateEnum.failed,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
