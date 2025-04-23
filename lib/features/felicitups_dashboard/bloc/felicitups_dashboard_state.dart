part of 'felicitups_dashboard_bloc.dart';

@freezed
class FelicitupsDashboardState with _$FelicitupsDashboardState {
  const factory FelicitupsDashboardState({
    required bool isLoading,
    required bool showSection,
    required List<bool> listBoolsTap,
    required List<FelicitupModel> listFelicitups,
    required List<FelicitupModel> listFelicitupsPast,
  }) = _FelicitupsDashboardState;

  factory FelicitupsDashboardState.initial() => FelicitupsDashboardState(
    isLoading: false,
    showSection: false,
    listBoolsTap: [true, false],
    listFelicitups: [],
    listFelicitupsPast: [],
  );
}
