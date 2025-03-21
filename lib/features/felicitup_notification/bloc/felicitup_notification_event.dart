part of 'felicitup_notification_bloc.dart';

@freezed
class FelicitupNotificationEvent with _$FelicitupNotificationEvent {
  const factory FelicitupNotificationEvent.changeLoading() = _changeLoading;
  const factory FelicitupNotificationEvent.getFelicitupData(String felicitupId) = _getFelicitupData;
  const factory FelicitupNotificationEvent.getCreatorData(String userId) = _getCreatorData;
  const factory FelicitupNotificationEvent.getInvitedUsersData(List<String> userIds) = _getInvitedUsersData;
  const factory FelicitupNotificationEvent.informParticipation(
    String felicitupId,
    String newStatus,
    String userName,
  ) = _informParticipation;
  const factory FelicitupNotificationEvent.deleteParticipant(String felicitupId, String userId) = _deleteParticipant;
  const factory FelicitupNotificationEvent.noEvent() = _noEvent;
}
