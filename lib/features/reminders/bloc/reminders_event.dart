part of 'reminders_bloc.dart';

@freezed
class RemindersEvent with _$RemindersEvent {
  const factory RemindersEvent.changeLoading() = _changeLoading;
}
