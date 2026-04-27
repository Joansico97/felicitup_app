part of 'people_past_felicitup_bloc.dart';

@freezed
abstract class PeoplePastFelicitupState with _$PeoplePastFelicitupState {
  const factory PeoplePastFelicitupState({
    required bool isLoading,
    List<InvitedModel>? invitedUsers,
    List<UserModel>? friendList,
  }) = _PeoplePastFelicitupState;

  factory PeoplePastFelicitupState.initial() =>
      PeoplePastFelicitupState(isLoading: true);
}
