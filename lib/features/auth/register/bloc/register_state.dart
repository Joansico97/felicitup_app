part of 'register_bloc.dart';

enum RegisterStatus {
  none,
  initial,
  formFinished,
  validateCode,
  success,
  finished,
  federated,
  federatedFinished,
  error,
}

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    required bool isLoading,
    required int currentStep,
    required RegisterStatus status,
    required String errorMessage,
    String? name,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    String? genre,
    String? phone,
    String? isoCode,
    String? verificationId,
    DateTime? birthDate,
    UserModel? user,
    Map<String, String>? federatedUser,
  }) = _RegisterState;

  factory RegisterState.initial() => RegisterState(
    isLoading: false,
    status: RegisterStatus.initial,
    errorMessage: '',
    currentStep: 0,
  );

  factory RegisterState.fromJson(Map<String, dynamic> json) =>
      _$RegisterStateFromJson(json);
}
