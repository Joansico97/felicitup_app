part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.changeLoading() = _changeLoading;
  const factory AppEvent.closeRememberSection() = _closeRememberSection;
  const factory AppEvent.checkAppStatus() = _checkAppStatus;
  const factory AppEvent.loadUserData() = _loadUserData;
  const factory AppEvent.loadProvUserData(Map<String, dynamic> federatedData) =
      _loadProvUserData;
  const factory AppEvent.updateMatchList(List<String> phoneList) =
      _updateMatchList;
  const factory AppEvent.initializeNotifications() = _initializeNotifications;
  const factory AppEvent.requestManualPermissions() = _requestManualPermissions;
  const factory AppEvent.deleterPermissions() = _deleterPermissions;
  const factory AppEvent.handleRemoteMessage(RemoteMessage message) =
      _handleRemoteMessage;
  const factory AppEvent.getFCMToken() = _getFCMToken;
  const factory AppEvent.logout() = _logout;
  const factory AppEvent.startGlobalTimer({required Duration duration}) =
      _appEventStartGlobalTimer;
  const factory AppEvent.stopGlobalTimer() =
      _appEventStopGlobalTimer; // Opcional
  const factory AppEvent.globalTimerTick() = _appEventGlobalTimerTick;
}
