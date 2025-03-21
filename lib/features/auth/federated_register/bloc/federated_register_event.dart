part of 'federated_register_bloc.dart';

@freezed
class FederatedRegisterEvent with _$FederatedRegisterEvent {
  const factory FederatedRegisterEvent.changeLoading() = _changeLoading;
  const factory FederatedRegisterEvent.initRegister(
    String name,
    String lastName,
    String gender,
    DateTime birthDate,
  ) = _initRegister;
  const factory FederatedRegisterEvent.savePhoneInfo(
    String phone,
    String isoCode,
  ) = _savePhoneInfo;
  const factory FederatedRegisterEvent.initValidation() = _initValidation;
  const factory FederatedRegisterEvent.setUserInfoRemaning() = _setUserInfo;
  const factory FederatedRegisterEvent.finishEvent() = _finishEvent;
}
