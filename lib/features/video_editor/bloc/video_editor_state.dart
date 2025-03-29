part of 'video_editor_bloc.dart';

@freezed
class VideoEditorState with _$VideoEditorState {
  const factory VideoEditorState({
    required bool isLoading,
    required bool isFullScreen,
    required String currentSelectedVideo,
    required Duration duration,
    required Duration position,
    required bool isPlaying,
    VideoPlayerController? videoPlayerController,
    FelicitupModel? currentFelicitup,
  }) = _VideoEditorState;

  factory VideoEditorState.initial() => VideoEditorState(
        isLoading: false,
        currentSelectedVideo: '',
        isFullScreen: false,
        duration: Duration.zero,
        position: Duration.zero,
        isPlaying: false,
      );
}
