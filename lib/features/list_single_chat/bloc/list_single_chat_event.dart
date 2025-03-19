part of 'list_single_chat_bloc.dart';

@freezed
class ListSingleChatEvent with _$ListSingleChatEvent {
  const factory ListSingleChatEvent.changeLoading() = _changeLoading;
}
