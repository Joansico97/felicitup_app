part of 'phone_verify_int_bloc.dart';

@freezed
class PhoneVerifyIntState with _$PhoneVerifyIntState {
  const factory PhoneVerifyIntState({
    required bool isLoading,
    required bool finished,
    required int currentStep,
    String? phoneNumber,
    String? isoCode,
    String? verificationId,
  }) = _PhoneVerifyIntState;

  factory PhoneVerifyIntState.initial() => const PhoneVerifyIntState(
    currentStep: 0,
    isLoading: false,
    finished: false,
  );
}
