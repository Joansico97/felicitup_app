part of 'info_felicitup_bloc.dart';

@freezed
class InfoFelicitupEvent with _$InfoFelicitupEvent {
  const factory InfoFelicitupEvent.changeLoading() = _changeLoading;
  const factory InfoFelicitupEvent.sendFelicitup(String felicitupId) = _sendFelicitup;
  const factory InfoFelicitupEvent.updateDateFelicitup(String felicitupId, DateTime newDate) = _updateDateFelicitup;
}
