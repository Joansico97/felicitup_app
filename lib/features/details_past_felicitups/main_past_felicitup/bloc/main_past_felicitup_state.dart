part of 'main_past_felicitup_bloc.dart';

@freezed
class MainPastFelicitupState with _$MainPastFelicitupState {
  const factory MainPastFelicitupState({
    required bool isLoading,
  }) = _MainPastFelicitupState;

  factory MainPastFelicitupState.initial() => MainPastFelicitupState(
        isLoading: true,
      );
}
