part of 'single_chat_bloc.dart';

@freezed
class SingleChatEvent with _$SingleChatEvent {
  const factory SingleChatEvent.changeIsLoading() = _changeIsLoading;
}
