part of 'video_editor_bloc.dart';

@freezed
class VideoEditorState with _$VideoEditorState {
  const factory VideoEditorState({
    required bool isLoading,
    required String currentSelectedVideo,
  }) = _VideoEditorState;

  factory VideoEditorState.initial() => VideoEditorState(
        isLoading: false,
        currentSelectedVideo: '',
      );
}
