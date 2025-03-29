part of 'video_editor_bloc.dart';

@freezed
class VideoEditorEvent with _$VideoEditorEvent {
  const factory VideoEditorEvent.changeLoading() = _changeLoading;
  const factory VideoEditorEvent.changeFullScreen() = _changeFullScreen;
  const factory VideoEditorEvent.setDuraton(Duration duration) = _setDuraton;
  const factory VideoEditorEvent.setPosition(Duration position) = _setPosition;
  const factory VideoEditorEvent.getFelicitupInfo(String felicitupId) = _getFelicitupInfo;
  const factory VideoEditorEvent.initializeVideoController(String url) = _initializeVideoController;
  const factory VideoEditorEvent.setUrlVideo(String url) = _setUrlVideo;
  const factory VideoEditorEvent.uploadUserVideo(String felicitupId, File file) = _uploadUserVideo;
  const factory VideoEditorEvent.generateThumbnail(String filePath) = _generateThumbnail;
  const factory VideoEditorEvent.updateParticipantInfo(String felicitupId, String url) = _updateParticipantInfo;
}
