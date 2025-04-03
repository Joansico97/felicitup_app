part of 'single_chat_bloc.dart';

@freezed
class SingleChatEvent with _$SingleChatEvent {
  const factory SingleChatEvent.changeIsLoading() = _changeIsLoading;
  const factory SingleChatEvent.setCurrentChatId(String chatId) = _setCurrentChatId;
  const factory SingleChatEvent.sendMessage({
    required ChatMessageModel chatMessage,
    required String chatId,
    required String userId,
    required String userName,
  }) = _sendMessage;
  const factory SingleChatEvent.startListening(String chatId) = _startListening;
  const factory SingleChatEvent.recivedData(List<ChatMessageModel> listMessages) = _recivedData;
}
