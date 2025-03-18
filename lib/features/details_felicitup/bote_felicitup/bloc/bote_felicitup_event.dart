part of 'bote_felicitup_bloc.dart';

@freezed
class BoteFelicitupEvent with _$BoteFelicitupEvent {
  const factory BoteFelicitupEvent.changeLoading() = _changeLoading;
  const factory BoteFelicitupEvent.startListening(String felicitupId) = _startListening;
  const factory BoteFelicitupEvent.recivedData(List<InvitedModel> invitedUsers) = _recivedData;
}
