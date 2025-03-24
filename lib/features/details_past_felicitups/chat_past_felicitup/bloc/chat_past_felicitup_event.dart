part of 'chat_past_felicitup_bloc.dart';

@freezed
class ChatPastFelicitupEvent with _$ChatPastFelicitupEvent {
  const factory ChatPastFelicitupEvent.asignCurrentChat(String chatId) = _asignCurrentChat;
  const factory ChatPastFelicitupEvent.sendMessage(
    ChatMessageModel chatMessage,
    FelicitupModel felicitup,
    String userId,
    String userName,
  ) = _sendMessage;
  const factory ChatPastFelicitupEvent.startListening(String chatId) = _startListening;
  const factory ChatPastFelicitupEvent.recivedData(List<ChatMessageModel> listMessages) = _recivedData;
}
