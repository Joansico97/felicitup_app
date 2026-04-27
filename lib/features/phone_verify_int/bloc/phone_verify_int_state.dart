part of 'phone_verify_int_bloc.dart';

enum PhoneVerifyStatus { none, error, success }

@freezed
abstract class PhoneVerifyIntState with _$PhoneVerifyIntState {
  const factory PhoneVerifyIntState({
    required bool isLoading,
    required bool finished,
    required int currentStep,
    required String userId,
    required PhoneVerifyStatus status,
    String? phoneNumber,
    String? hashedPhoneNumber,
    String? isoCode,
    String? verificationId,
    String? errorMessage,
  }) = _PhoneVerifyIntState;

  factory PhoneVerifyIntState.initial() => const PhoneVerifyIntState(
    currentStep: 0,
    isLoading: false,
    finished: false,
    status: PhoneVerifyStatus.none,
    userId: '',
  );
}
