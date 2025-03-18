part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.changeLoading() = _changeLoading;
  const factory LoginEvent.loginEvent(String email, String password) = _loginEvent;
}
