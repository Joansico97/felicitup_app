part of 'video_felicitup_bloc.dart';

@freezed
abstract class VideoFelicitupState with _$VideoFelicitupState {
  const factory VideoFelicitupState({
    required bool isLoading,
    required bool showModal,
    List<InvitedModel>? invitedUsers,
    String? errorMessage,
  }) = _VideoFelicitupState;

  factory VideoFelicitupState.initial() =>
      VideoFelicitupState(isLoading: false, showModal: false);
}
