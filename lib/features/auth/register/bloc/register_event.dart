part of 'register_bloc.dart';

@freezed
class RegisterEvent with _$RegisterEvent {
  const factory RegisterEvent.changeLoading() = _changeLoading;
  const factory RegisterEvent.initRegister(
    String name,
    String lastName,
    String email,
    String password,
    String confirmPassword,
    String genre,
    DateTime birthDate,
  ) = _initRegister;
  const factory RegisterEvent.savePhoneInfo(String phone, String isoCode) =
      _savePhoneInfo;
  const factory RegisterEvent.googleLoginEvent() = _googleLoginEvent;
  const factory RegisterEvent.appleLoginEvent() = _appleLoginEvent;
  const factory RegisterEvent.initValidation() = _initValidation;
  const factory RegisterEvent.validateCode(String code) = _validateCode;
  const factory RegisterEvent.registerEvent(bool isEmail) = _registerEvent;
  const factory RegisterEvent.setUserInfo(UserCredential credential) =
      _setUserInfo;
  const factory RegisterEvent.finishEvent() = _finishEvent;
}
