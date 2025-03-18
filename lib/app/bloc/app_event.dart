part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.changeLoading() = _changeLoading;
  const factory AppEvent.loadUserData() = _loadUserData;
  const factory AppEvent.logout() = _logout;
}
