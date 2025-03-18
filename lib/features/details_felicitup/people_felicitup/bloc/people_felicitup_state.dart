part of 'people_felicitup_bloc.dart';

@freezed
class PeopleFelicitupState with _$PeopleFelicitupState {
  const factory PeopleFelicitupState({
    required bool isLoading,
  }) = _PeopleFelicitupState;

  factory PeopleFelicitupState.initial() => PeopleFelicitupState(
        isLoading: false,
      );
}
