part of 'notifications_settings_bloc.dart';

@freezed
abstract class NotificationsSettingsState with _$NotificationsSettingsState {
  const factory NotificationsSettingsState({required bool isLoading}) =
      _NotificationsSettingsState;

  factory NotificationsSettingsState.initial() =>
      NotificationsSettingsState(isLoading: false);
}
