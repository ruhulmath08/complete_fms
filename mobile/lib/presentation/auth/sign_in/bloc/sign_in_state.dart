part of 'sign_in_bloc.dart';

enum SignInStateEnum { initial, loading, failed, success }

class SignInState extends Equatable {
  final SignInStateEnum initial;
  final String userName;
  final String password;
  final String errorMessage;

  const SignInState({
    required this.initial,
    required this.userName,
    required this.password,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [initial, userName, password, errorMessage];

  SignInState copyWith({
    SignInStateEnum? initial,
    String? userName,
    String? password,
    String? errorMessage,
  }) {
    return SignInState(
      initial: initial ?? this.initial,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
