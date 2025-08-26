part of 'details_felicitup_dashboard_bloc.dart';

enum DetailsStatus { initial, failure, success }

@freezed
class DetailsFelicitupDashboardState with _$DetailsFelicitupDashboardState {
  const factory DetailsFelicitupDashboardState({
    required bool isLoading,
    required int currentIndex,
    required DetailsStatus status,
    FelicitupModel? felicitup,
    String? errorMessage,
    String? initialSubRoute,
    String? chatIdFromNotification,
  }) = _DetailsFelicitupDashboardState;

  factory DetailsFelicitupDashboardState.initial() =>
      DetailsFelicitupDashboardState(
        isLoading: false,
        currentIndex: 1,
        status: DetailsStatus.initial,
      );
}
