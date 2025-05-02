part of 'forgot_password_bloc.dart';

enum Status { initial, loading, success, error }

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState({
    required bool isLoading,
    required Status status,
  }) = _ForgotPasswordState;

  factory ForgotPasswordState.initial() =>
      ForgotPasswordState(isLoading: false, status: Status.initial);
}
