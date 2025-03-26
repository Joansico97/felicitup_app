part of 'people_felicitup_bloc.dart';

@freezed
class PeopleFelicitupState with _$PeopleFelicitupState {
  const factory PeopleFelicitupState({
    required bool isLoading,
    List<InvitedModel>? invitedUsers,
    required List<InvitedModel> invitedContacts,
    required List<UserModel> friendList,
  }) = _PeopleFelicitupState;

  factory PeopleFelicitupState.initial() => PeopleFelicitupState(
        isLoading: false,
        invitedContacts: [],
        friendList: [],
      );
}
