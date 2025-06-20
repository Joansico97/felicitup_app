part of 'login_bloc.dart';

enum LoginStatus { initial, inProgress, success, federated, error }

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    required bool isLoading,
    required LoginStatus status,
    required String errorMessage,
    required bool isFirstTime,
  }) = _LoginState;

  factory LoginState.initial() => LoginState(
    isLoading: false,
    status: LoginStatus.initial,
    errorMessage: '',
    isFirstTime: true,
  );

  factory LoginState.fromJson(Map<String, dynamic> json) =>
      _$LoginStateFromJson(json);
}
