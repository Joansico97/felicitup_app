part of 'details_felicitup_dashboard_bloc.dart';

@freezed
class DetailsFelicitupDashboardState with _$DetailsFelicitupDashboardState {
  const factory DetailsFelicitupDashboardState({
    required bool isLoading,
    required int currentIndex,
    required String errorMessage,
    FelicitupModel? felicitup,
  }) = _DetailsFelicitupDashboardState;

  factory DetailsFelicitupDashboardState.initial() => DetailsFelicitupDashboardState(
        isLoading: false,
        currentIndex: 1,
        errorMessage: '',
      );
}
