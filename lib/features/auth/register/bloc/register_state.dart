part of 'register_bloc.dart';

enum RegisterStatus { initial, formFinished, validateCode, success, finished, error }

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    required bool isLoading,
    required RegisterStatus status,
    required String errorMessage,
    String? name,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    String? gender,
    String? phone,
    String? isoCode,
    DateTime? birthDate,
  }) = _RegisterState;

  factory RegisterState.initial() => RegisterState(
        isLoading: false,
        status: RegisterStatus.initial,
        errorMessage: '',
      );
}
