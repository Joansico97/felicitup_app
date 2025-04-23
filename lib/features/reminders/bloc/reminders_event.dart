part of 'reminders_bloc.dart';

@freezed
class RemindersEvent with _$RemindersEvent {
  const factory RemindersEvent.changeLoading() = _changeLoading;
  const factory RemindersEvent.createSingleChat(
    SingleChatModel singleChatData,
  ) = _createSingleChat;
}
