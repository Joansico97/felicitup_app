part of 'video_editor_bloc.dart';

@freezed
class VideoEditorEvent with _$VideoEditorEvent {
  const factory VideoEditorEvent.changeLoading() = _changeLoading;
}
