part of 'felicitup_notification_bloc.dart';

@freezed
class FelicitupNotificationState with _$FelicitupNotificationState {
  const factory FelicitupNotificationState({
    required bool isLoading,
    FelicitupModel? currentFelicitup,
    UserModel? creator,
    List<UserModel>? invitedUsers,
  }) = _FelicitupNotificationState;

  factory FelicitupNotificationState.initial() => FelicitupNotificationState(
        isLoading: false,
      );
}
