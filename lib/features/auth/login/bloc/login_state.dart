part of 'login_bloc.dart';

enum LoginStatus { initial, success, error }

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    required bool isLoading,
    required LoginStatus status,
    required String errorMessage,
  }) = _LoginState;

  factory LoginState.initial() => LoginState(
        isLoading: false,
        status: LoginStatus.initial,
        errorMessage: '',
      );
}
