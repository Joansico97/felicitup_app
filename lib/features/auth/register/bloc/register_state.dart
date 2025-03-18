part of 'register_bloc.dart';

enum RegisterStatus { initial, loading, success, error }

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    required bool isLoading,
    required RegisterStatus status,
    required String errorMessage,
  }) = _RegisterState;

  factory RegisterState.initial() => RegisterState(
        isLoading: false,
        status: RegisterStatus.initial,
        errorMessage: '',
      );
}
