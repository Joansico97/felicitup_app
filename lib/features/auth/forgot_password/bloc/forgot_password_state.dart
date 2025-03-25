part of 'forgot_password_bloc.dart';

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState({
    required bool isLoading,
  }) = _ForgotPasswordState;

  factory ForgotPasswordState.initial() => ForgotPasswordState(
        isLoading: false,
      );
}
