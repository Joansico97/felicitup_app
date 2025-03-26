part of 'info_felicitup_bloc.dart';

@freezed
class InfoFelicitupState with _$InfoFelicitupState {
  const factory InfoFelicitupState({
    required bool isLoading,
    required List<OwnerModel> ownersList,
    required List<InvitedModel> invitedContacts,
    required List<UserModel> friendList,
  }) = _InfoFelicitupState;

  factory InfoFelicitupState.initial() => InfoFelicitupState(
        isLoading: false,
        ownersList: [],
        invitedContacts: [],
        friendList: [],
      );
}
