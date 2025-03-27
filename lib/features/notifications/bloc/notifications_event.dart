part of 'notifications_bloc.dart';

@freezed
class NotificationsEvent with _$NotificationsEvent {
  const factory NotificationsEvent.changeLoading() = _changeLoading;
  const factory NotificationsEvent.getNotifications() = _getNotifications;
  const factory NotificationsEvent.deleteNotification(String notificationId) = _deleteNotification;
}
