part of 'video_felicitup_bloc.dart';

@freezed
class VideoFelicitupState with _$VideoFelicitupState {
  const factory VideoFelicitupState({
    required bool isLoading,
    required bool showModal,
    List<InvitedModel>? invitedUsers,
  }) = _VideoFelicitupState;

  factory VideoFelicitupState.initial() => VideoFelicitupState(
        isLoading: false,
        showModal: false,
      );
}
