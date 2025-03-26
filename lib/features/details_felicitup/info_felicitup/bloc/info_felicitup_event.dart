part of 'info_felicitup_bloc.dart';

@freezed
class InfoFelicitupEvent with _$InfoFelicitupEvent {
  const factory InfoFelicitupEvent.changeLoading() = _changeLoading;
  const factory InfoFelicitupEvent.sendFelicitup(String felicitupId) = _sendFelicitup;
  const factory InfoFelicitupEvent.updateDateFelicitup(String felicitupId, DateTime newDate) = _updateDateFelicitup;
  const factory InfoFelicitupEvent.addToOwnerList(OwnerModel felicitupOwner) = _addToOwnerList;
  const factory InfoFelicitupEvent.updateFelicitupOwners(String felicitupId) = _updateFelicitupOwners;
  const factory InfoFelicitupEvent.addParticipant(InvitedModel participant) = _addParticipant;
  const factory InfoFelicitupEvent.loadFriendsData(List<String> usersIds) = _loadFriendsData;
}
