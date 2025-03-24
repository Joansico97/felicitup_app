part of 'details_past_felicitup_dashboard_bloc.dart';

@freezed
class DetailsPastFelicitupDashboardState with _$DetailsPastFelicitupDashboardState {
  const factory DetailsPastFelicitupDashboardState({
    required bool isLoading,
    required int currentIndex,
    required String errorMessage,
    FelicitupModel? felicitup,
  }) = _DetailsPastFelicitupDashboardState;

  factory DetailsPastFelicitupDashboardState.initial() => DetailsPastFelicitupDashboardState(
        isLoading: false,
        currentIndex: 1,
        errorMessage: '',
      );
}
