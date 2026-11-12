part of 'sign_in_bloc.dart';

sealed class SignInEvent {
  const SignInEvent();
}

final class SignInUsernameChange extends SignInEvent {
  const SignInUsernameChange({required this.username});

  final String username;
}

final class SignInPasswordChange extends SignInEvent {
  const SignInPasswordChange({required this.password});

  final String password;
}

final class SignInSubmitted extends SignInEvent {
  const SignInSubmitted();
}
