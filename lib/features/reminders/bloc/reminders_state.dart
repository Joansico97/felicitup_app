part of 'reminders_bloc.dart';

@freezed
abstract class RemindersState with _$RemindersState {
  const factory RemindersState({
    // required List<Reminder> reminders,
    required bool isLoading,
  }) = _RemindersState;

  factory RemindersState.initial() => const RemindersState(isLoading: false);
}
