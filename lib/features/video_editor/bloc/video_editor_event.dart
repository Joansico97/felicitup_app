part of 'video_editor_bloc.dart';

@freezed
class VideoEditorEvent with _$VideoEditorEvent {
  const factory VideoEditorEvent.changeLoading() = _changeLoading;
  const factory VideoEditorEvent.setUrlVideo(String url) = _setUrlVideo;
  const factory VideoEditorEvent.uploadUserVideo(String felicitupId, File file) = _uploadUserVideo;
  const factory VideoEditorEvent.updateParticipantInfo(String felicitupId, String url) = _updateParticipantInfo;
}
