part of 'people_past_felicitup_bloc.dart';

@freezed
class PeoplePastFelicitupState with _$PeoplePastFelicitupState {
  const factory PeoplePastFelicitupState({
    required bool isLoading,
    List<InvitedModel>? invitedUsers,
  }) = _PeoplePastFelicitupState;

  factory PeoplePastFelicitupState.initial() => PeoplePastFelicitupState(
        isLoading: true,
      );
}
