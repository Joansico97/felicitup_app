part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.changeLoading() = _changeLoading;
  const factory LoginEvent.loginEvent(String email, String password) =
      _loginEvent;
  const factory LoginEvent.setUserInfo(UserModel user) = _setUserInfo;
  const factory LoginEvent.changeEvent() = _changeEvent;
  const factory LoginEvent.changeFirstTimeRedirect() = _changeFirstTimeRedirect;
  const factory LoginEvent.googleLoginEvent() = _googleLoginEvent;
  const factory LoginEvent.appleLoginEvent() = _appleLoginEvent;
}
