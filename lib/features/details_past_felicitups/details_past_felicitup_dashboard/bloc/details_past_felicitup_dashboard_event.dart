part of 'details_past_felicitup_dashboard_bloc.dart';

@freezed
class DetailsPastFelicitupDashboardEvent with _$DetailsPastFelicitupDashboardEvent {
  const factory DetailsPastFelicitupDashboardEvent.changeLoading() = _changeLoading;
  const factory DetailsPastFelicitupDashboardEvent.noEvent() = _noEvent;
  const factory DetailsPastFelicitupDashboardEvent.changeCurrentIndex(int index) = _changeCurrentIndex;
  const factory DetailsPastFelicitupDashboardEvent.asignCurrentChat(String chatId) = _asignCurrentChat;
  const factory DetailsPastFelicitupDashboardEvent.getFelicitupInfo(String felicitupId) = _getFelicitupInfo;
}
