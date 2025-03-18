part of 'people_felicitup_bloc.dart';

@freezed
class PeopleFelicitupEvent with _$PeopleFelicitupEvent {
  const factory PeopleFelicitupEvent.changeLoading() = _changeLoading;
  const factory PeopleFelicitupEvent.startListening(String felicitupId) = _startListening;
  const factory PeopleFelicitupEvent.recivedData(List<InvitedModel> invitedUsers) = _recivedData;
}
