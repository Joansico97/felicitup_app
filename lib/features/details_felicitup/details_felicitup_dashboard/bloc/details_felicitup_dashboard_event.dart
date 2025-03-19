part of 'details_felicitup_dashboard_bloc.dart';

@freezed
class DetailsFelicitupDashboardEvent with _$DetailsFelicitupDashboardEvent {
  const factory DetailsFelicitupDashboardEvent.changeCurrentIndex(int index) = _changeCurrentIndex;
  const factory DetailsFelicitupDashboardEvent.noEvent() = _noEvent;
  const factory DetailsFelicitupDashboardEvent.asignCurrentChat(String chatId) = _asignCurrentChat;
  const factory DetailsFelicitupDashboardEvent.getFelicitupInfo(String felicitupId) = _getFelicitupInfo;
}
