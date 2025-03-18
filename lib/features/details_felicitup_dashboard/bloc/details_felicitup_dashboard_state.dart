part of 'details_felicitup_dashboard_bloc.dart';

@freezed
class DetailsFelicitupDashboardState with _$DetailsFelicitupDashboardState {
  const factory DetailsFelicitupDashboardState({
    required bool isLoading,
    required String errorMessage,
  }) = _DetailsFelicitupDashboardState;

  factory DetailsFelicitupDashboardState.initial() => DetailsFelicitupDashboardState(
        isLoading: false,
        errorMessage: '',
      );
}
