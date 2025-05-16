part of 'federated_register_bloc.dart';

@freezed
class FederatedRegisterEvent with _$FederatedRegisterEvent {
  const factory FederatedRegisterEvent.changeLoading() = _changeLoading;
  const factory FederatedRegisterEvent.backStep() = _backStep;
  const factory FederatedRegisterEvent.initRegister({
    required String name,
    required String lastName,
    required String genre,
    required DateTime birthDate,
  }) = _initRegister;
  const factory FederatedRegisterEvent.savePhoneInfo(
    String phone,
    String isoCode,
  ) = _savePhoneInfo;
  const factory FederatedRegisterEvent.initValidation() = _initValidation;
  const factory FederatedRegisterEvent.validateCode(String code) =
      _validateCode;
  const factory FederatedRegisterEvent.setUserInfoRemaning() = _setUserInfo;
  const factory FederatedRegisterEvent.finishEvent() = _finishEvent;
}
