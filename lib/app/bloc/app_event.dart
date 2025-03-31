part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.changeLoading() = _changeLoading;
  const factory AppEvent.loadUserData() = _loadUserData;
  const factory AppEvent.updateMatchList(List<String> phoneList) = _updateMatchList;
  const factory AppEvent.initializeNotifications() = _initializeNotifications;
  const factory AppEvent.requestManualPermissions() = _requestManualPermissions;
  const factory AppEvent.deleterPermissions() = _deleterPermissions;
  const factory AppEvent.handleRemoteMessage(RemoteMessage message) = _handleRemoteMessage;
  const factory AppEvent.getFCMToken() = _getFCMToken;
  const factory AppEvent.logout() = _logout;
}
