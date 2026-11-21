part of 'sign_in_bloc.dart';

enum SignInStateEnum { initial, loading, failed, success }

class SignInState extends Equatable {
  final SignInStateEnum statusEnum;
  final String userName;
  final String password;
  final String errorMessage;

  const SignInState({
    required this.statusEnum,
    required this.userName,
    required this.password,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [statusEnum, userName, password, errorMessage];

  SignInState copyWith({
    SignInStateEnum? statusEnum,
    String? userName,
    String? password,
    String? errorMessage,
  }) {
    return SignInState(
      statusEnum: statusEnum ?? this.statusEnum,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
