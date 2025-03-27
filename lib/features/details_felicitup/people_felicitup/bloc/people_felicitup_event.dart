part of 'people_felicitup_bloc.dart';

@freezed
class PeopleFelicitupEvent with _$PeopleFelicitupEvent {
  const factory PeopleFelicitupEvent.changeLoading() = _changeLoading;
  const factory PeopleFelicitupEvent.loadFriendsData(List<String> usersIds) = _loadFriendsData;
  const factory PeopleFelicitupEvent.sendNotification(
    String userId,
    String name,
    String felicitupId,
  ) = _sendNotification;
  const factory PeopleFelicitupEvent.informParticipation({
    required String felicitupId,
    required String felicitupOwnerId,
    required String newStatus,
    required String name,
  }) = _informParticipation;
  const factory PeopleFelicitupEvent.addParticipant(InvitedModel participant) = _addParticipant;
  const factory PeopleFelicitupEvent.updateParticipantsList(String felicitupId) = _updateParticipantsList;
  const factory PeopleFelicitupEvent.deleteParticipant(String felicitupId, String userId) = _deleteParticipant;
  const factory PeopleFelicitupEvent.startListening(String felicitupId) = _startListening;
  const factory PeopleFelicitupEvent.recivedData(List<InvitedModel> invitedUsers) = _recivedData;
}
