part of 'video_felicitup_bloc.dart';

@freezed
class VideoFelicitupEvent with _$VideoFelicitupEvent {
  const factory VideoFelicitupEvent.changeLoading() = _changeLoading;
  const factory VideoFelicitupEvent.mergeVideos(String felicitupId, List<String> listVideos) = _mergeVideos;
  const factory VideoFelicitupEvent.startListening(String felicitupId) = _startListening;
  const factory VideoFelicitupEvent.recivedData(List<InvitedModel> invitedUsers) = _recivedData;
}
