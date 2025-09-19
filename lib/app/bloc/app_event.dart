part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.onAppStarted() = _onAppStarted;
  const factory AppEvent.changeLoadContacts() = changeLoadContacts;
  const factory AppEvent.loadContacts() = _loadContacts;
  const factory AppEvent.closeRememberSection() = _closeRememberSection;
  const factory AppEvent.checkAppStatus() = _checkAppStatus;
  const factory AppEvent.loadUserData() = _loadUserData;
  const factory AppEvent.loadProvUserData(Map<String, dynamic> federatedData) =
      _loadProvUserData;
  const factory AppEvent.syncContacts(String isoCode) = _syncContacts;
  const factory AppEvent.updateMatchListFromContacts() =
      _updateMatchListFromContacts;
  const factory AppEvent.updateMatchList(List<String> phoneList) =
      _updateMatchList;
  const factory AppEvent.initializeNotifications() = _initializeNotifications;
  const factory AppEvent.requestManualPermissions() = _requestManualPermissions;
  const factory AppEvent.requestManualContactsPermissions() =
      _requestManualContactsPermissions;
  const factory AppEvent.notificationReceived(Map<String, dynamic> payload) =
      _notificationReceived;
  const factory AppEvent.clearPendingNotification() = _clearPendingNotification;
  const factory AppEvent.deleterPermissions() = _deleterPermissions;
  const factory AppEvent.handleRemoteMessage(RemoteMessage message) =
      _handleRemoteMessage;
  const factory AppEvent.getFCMToken() = _getFCMToken;
  const factory AppEvent.logout() = _logout;
}
