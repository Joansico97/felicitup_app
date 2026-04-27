part of 'video_editor_bloc.dart';

@freezed
class VideoEditorEvent with _$VideoEditorEvent {
  const factory VideoEditorEvent.changeLoading() = _changeLoading;
  const factory VideoEditorEvent.changeFullScreen() = _changeFullScreen;
  const factory VideoEditorEvent.setDuraton(Duration duration) = _setDuraton;
  const factory VideoEditorEvent.setPosition(Duration position) = _setPosition;
  const factory VideoEditorEvent.getFelicitupInfo(String felicitupId) =
      _getFelicitupInfo;
  const factory VideoEditorEvent.initializeVideoController(String url) =
      _initializeVideoController;
  const factory VideoEditorEvent.disposeVideoController() =
      _disposeVideoController;
  const factory VideoEditorEvent.setUrlVideo(String url) = _setUrlVideo;
  const factory VideoEditorEvent.normalizeVideo({
    required String url,
    required String userId,
    required String felicitupId,
  }) = _normalizeVideo;
  const factory VideoEditorEvent.uploadUserVideo(
    String felicitupId,
    File file,
    String userId,
    String userName,
    String felicitupCreatorId,
  ) = _uploadUserVideo;
  const factory VideoEditorEvent.generateThumbnail(String filePath) =
      _generateThumbnail;
  const factory VideoEditorEvent.reportUserVideo({
    required String felicitupId,
    required String userId,
    required String videoUrl,
  }) = _reportUserVideo;
  const factory VideoEditorEvent.updateParticipantInfo(
    String felicitupId,
    String url,
  ) = _updateParticipantInfo;
  const factory VideoEditorEvent.sendNotification(
    String userId,
    String userName,
    String felicitupId,
  ) = _sendNotification;
}
