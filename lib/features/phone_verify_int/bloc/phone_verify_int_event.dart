part of 'phone_verify_int_bloc.dart';

@freezed
class PhoneVerifyIntEvent with _$PhoneVerifyIntEvent {
  const factory PhoneVerifyIntEvent.savePhoneInfo({
    required String isoCode,
    required String phoneNumber,
    required String userId,
  }) = _savePhoneInfo;
  const factory PhoneVerifyIntEvent.initValidation() = _initValidation;
  const factory PhoneVerifyIntEvent.validateCode(String code) = _validateCode;
}
