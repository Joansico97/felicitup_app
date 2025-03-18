part of 'info_felicitup_bloc.dart';

@freezed
class InfoFelicitupState with _$InfoFelicitupState {
  const factory InfoFelicitupState({
    required bool isLoading,
  }) = _InfoFelicitupState;

  factory InfoFelicitupState.initial() => InfoFelicitupState(
        isLoading: false,
      );
}
