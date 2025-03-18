part of 'felicitups_dashboard_bloc.dart';

@freezed
class FelicitupsDashboardEvent with _$FelicitupsDashboardEvent {
  const factory FelicitupsDashboardEvent.changeLoading() = _changeLoading;
  const factory FelicitupsDashboardEvent.changeListBoolsTap(int index, PageController controller) = _changeListBoolsTap;
  const factory FelicitupsDashboardEvent.setLike(String felicitupId, String userId) = _setLike;
  const factory FelicitupsDashboardEvent.startListening() = _startListening;
  const factory FelicitupsDashboardEvent.recivedData(List<FelicitupModel> listFelicitups) = _recivedData;
  const factory FelicitupsDashboardEvent.recivedPastData(List<FelicitupModel> listFelicitups) = _recivedPastData;
}
