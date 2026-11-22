part of 'sign_in_bloc.dart';

enum SignInStateEnum { initial, loading, failed, success }

abstract final class SignInErrorCode {
  static const emptyFields = 'EMPTY_FIELDS';
  static const invalidEmail = 'INVALID_EMAIL';
  static const invalidCredentials = 'INVALID_CREDENTIALS';
}

class SignInState extends Equatable {
  final SignInStateEnum statusEnum;
  final String userName;
  final String password;
  final String errorMessage;
  final String errorCode;

  const SignInState({
    required this.statusEnum,
    required this.userName,
    required this.password,
    required this.errorMessage,
    this.errorCode = '',
  });

  @override
  List<Object?> get props => [
    statusEnum,
    userName,
    password,
    errorMessage,
    errorCode,
  ];

  SignInState copyWith({
    SignInStateEnum? statusEnum,
    String? userName,
    String? password,
    String? errorMessage,
    String? errorCode,
  }) {
    return SignInState(
      statusEnum: statusEnum ?? this.statusEnum,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
    );
  }
}
