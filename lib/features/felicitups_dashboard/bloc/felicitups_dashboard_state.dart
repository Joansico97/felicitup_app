part of 'felicitups_dashboard_bloc.dart';

enum FelicitupsDashboardStatus {
  initial,
  loading,
  success,
  error,
  likeSuccess,
  likeError,
  chatCreated,
}

@freezed
abstract class FelicitupsDashboardState with _$FelicitupsDashboardState {
  const factory FelicitupsDashboardState({
    required bool isLoading,
    required bool showSection,
    required int currentIndex,
    required List<FelicitupModel> listFelicitups,
    required List<FelicitupModel> listFelicitupsPast,
    required List<FelicitupModel> backUpListFelicitupsPast,
    required FelicitupsDashboardStatus status,
    SingleChatModel? createdChat,
    String? errorMessage,
  }) = _FelicitupsDashboardState;

  factory FelicitupsDashboardState.initial() => FelicitupsDashboardState(
    isLoading: false,
    showSection: false,
    currentIndex: 0,
    listFelicitups: [],
    listFelicitupsPast: [],
    backUpListFelicitupsPast: [],
    status: FelicitupsDashboardStatus.initial,
  );
}
