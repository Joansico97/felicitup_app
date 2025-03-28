part of 'message_felicitup_bloc.dart';

@freezed
class MessageFelicitupEvent with _$MessageFelicitupEvent {
  const factory MessageFelicitupEvent.loadMessages() = _loadMessages;
  const factory MessageFelicitupEvent.asignCurrentChat(String chatId) = _asignCurrentChat;
  const factory MessageFelicitupEvent.sendMessage(
    ChatMessageModel chatMessage,
    FelicitupModel felicitup,
    String userId,
    String userName,
  ) = _sendMessage;
  const factory MessageFelicitupEvent.setCurrentChatId(String chatId) = _setCurrentChatId;
  const factory MessageFelicitupEvent.startListening(String chatId) = _startListening;
  const factory MessageFelicitupEvent.recivedData(List<ChatMessageModel> listMessages) = _recivedData;
}
