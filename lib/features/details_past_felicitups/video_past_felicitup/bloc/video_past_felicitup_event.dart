part of 'video_past_felicitup_bloc.dart';

@freezed
class VideoPastFelicitupEvent with _$VideoPastFelicitupEvent {
  const factory VideoPastFelicitupEvent.changeLoading() = _changeLoading;
  const factory VideoPastFelicitupEvent.setUrlVideo(String url) = _setUrlVideo;
}
