part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.changeLoading() = _changeLoading;
  const factory AppEvent.loadUserData() = _loadUserData;
  const factory AppEvent.initializeNotifications() = _initializeNotifications;
  const factory AppEvent.handleRemoteMessage(RemoteMessage message) = _handleRemoteMessage;
  const factory AppEvent.logout() = _logout;
}
