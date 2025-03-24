part of 'video_past_felicitup_bloc.dart';

@freezed
class VideoPastFelicitupState with _$VideoPastFelicitupState {
  const factory VideoPastFelicitupState({
    required bool isLoading,
    required String currentSelectedVideo,
  }) = _VideoPastFelicitupState;

  factory VideoPastFelicitupState.initial() => VideoPastFelicitupState(
        isLoading: false,
        currentSelectedVideo: '',
      );
}
