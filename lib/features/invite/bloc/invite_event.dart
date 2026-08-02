part of 'invite_bloc.dart';

@freezed
class InviteEvent with _$InviteEvent {
  const factory InviteEvent.changeLoading() = _changeLoading;
  const factory InviteEvent.loadInviteData(String felicitupId) = _loadInviteData;
  const factory InviteEvent.joinFelicitup() = _joinFelicitup;
}
