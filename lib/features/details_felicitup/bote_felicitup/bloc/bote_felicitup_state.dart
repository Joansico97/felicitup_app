part of 'bote_felicitup_bloc.dart';

@freezed
class BoteFelicitupState with _$BoteFelicitupState {
  const factory BoteFelicitupState({
    required bool isLoading,
    int? boteQuantity,
    List<InvitedModel>? invitedUsers,
  }) = _BoteFelicitupState;

  factory BoteFelicitupState.initial() => BoteFelicitupState(
        isLoading: false,
      );
}
