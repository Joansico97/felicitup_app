part of 'notifications_settings_bloc.dart';

@freezed
class NotificationsSettingsEvent with _$NotificationsSettingsEvent {
  const factory NotificationsSettingsEvent.changeLoading() = _changeLoading;
}
