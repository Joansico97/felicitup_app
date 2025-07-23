part of 'register_bloc.dart';

@freezed
class RegisterEvent with _$RegisterEvent {
  const factory RegisterEvent.changeLoading() = _changeLoading;
  const factory RegisterEvent.changeStatus(RegisterStatus status) =
      _changeStatus;
  const factory RegisterEvent.previousStep() = _previousStep;
  const factory RegisterEvent.initRegister({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    DateTime? birthDate,
  }) = _initRegister;
  const factory RegisterEvent.savePhoneInfo(String phone, String isoCode) =
      _savePhoneInfo;
  const factory RegisterEvent.googleLoginEvent() = _googleLoginEvent;
  const factory RegisterEvent.appleLoginEvent() = _appleLoginEvent;
  const factory RegisterEvent.initValidation() = _initValidation;
  const factory RegisterEvent.verificationCompleted(String verificationId) =
      _verificationCompleted;
  const factory RegisterEvent.verificationFailed(String error) =
      _verificationFailed;
  const factory RegisterEvent.validateCode(String code) = _validateCode;
  const factory RegisterEvent.registerEvent(bool isEmail) = _registerEvent;
  const factory RegisterEvent.setUserInfo(UserCredential credential) =
      _setUserInfo;
  const factory RegisterEvent.deleteState() = _deleteState;
  const factory RegisterEvent.finishEvent() = _finishEvent;
}
