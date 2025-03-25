part of 'create_felicitup_bloc.dart';

@freezed
class CreateFelicitupEvent with _$CreateFelicitupEvent {
  const factory CreateFelicitupEvent.deleteCurrentFelicitup() = _deleteCurrentFelicitup;
  const factory CreateFelicitupEvent.previousStep() = _previousStep;
  const factory CreateFelicitupEvent.nextStep(int lenght) = _nextStep;
  const factory CreateFelicitupEvent.jumpToStep(int index) = _jumpToStep;
  const factory CreateFelicitupEvent.toggleHasVideo() = _toggleHasVideo;
  const factory CreateFelicitupEvent.toggleHasBote() = _toggleHasBote;
  const factory CreateFelicitupEvent.changeBoteQuantity(int quantity) = _changeBoteQuantity;
  const factory CreateFelicitupEvent.changeEventReason(String reason) = _changeEventReason;
  const factory CreateFelicitupEvent.changeFelicitupDate(DateTime felicitupDate) = _changeFelicitupDate;
  const factory CreateFelicitupEvent.changeFelicitupOwner(OwnerModel felicitupOwner) = _changeFelicitupOwner;
  const factory CreateFelicitupEvent.addParticipant(InvitedModel participant) = _addParticipant;
  const factory CreateFelicitupEvent.loadFriendsData(List<String> usersIds) = _loadFriendsData;
  const factory CreateFelicitupEvent.searchEvent(String value) = _searchEvent;
  const factory CreateFelicitupEvent.createFelicitup(String felicitupMessage) = _createFelicitup;
  const factory CreateFelicitupEvent.sendNotification(String felicitupId) = _sendNotification;
}
