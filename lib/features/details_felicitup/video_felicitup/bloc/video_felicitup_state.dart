part of 'video_felicitup_bloc.dart';

@freezed
class VideoFelicitupState with _$VideoFelicitupState {
  const factory VideoFelicitupState({
    required bool isLoading,
    List<InvitedModel>? invitedUsers,
  }) = _VideoFelicitupState;

  factory VideoFelicitupState.initial() => VideoFelicitupState(
        isLoading: false,
      );
}
