part of 'notifications_bloc.dart';

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    required bool isLoading,
    required List<PushMessageModel> notifications,
    required String errorMessage,
  }) = _NotificationsState;

  factory NotificationsState.initial() =>
      NotificationsState(isLoading: false, notifications: [], errorMessage: '');
}
