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
  const factory RegisterEvent.savePhoneInfo(
    String phone,
    String isoCode,
  ) = _savePhoneInfo;
  const factory RegisterEvent.initValidation() = _initValidation;
  const factory RegisterEvent.registerEvent() = _registerEvent;
  const factory RegisterEvent.setUserInfo(UserCredential credential) = _setUserInfo;
  const factory RegisterEvent.finishEvent() = _finishEvent;
}
