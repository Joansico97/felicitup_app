part of 'people_past_felicitup_bloc.dart';

@freezed
class PeoplePastFelicitupEvent with _$PeoplePastFelicitupEvent {
  const factory PeoplePastFelicitupEvent.changeLoading() = _changeLoading;
  const factory PeoplePastFelicitupEvent.startListening(String felicitupId) = _startListening;
  const factory PeoplePastFelicitupEvent.recivedData(List<InvitedModel> invitedUsers) = _recivedData;
}
