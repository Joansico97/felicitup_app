part of 'chat_past_felicitup_bloc.dart';

@freezed
class ChatPastFelicitupState with _$ChatPastFelicitupState {
  const factory ChatPastFelicitupState({
    required bool isLoading,
    required List<ChatMessageModel> messages,
  }) = _ChatPastFelicitupState;

  factory ChatPastFelicitupState.initial() => ChatPastFelicitupState(
        isLoading: false,
        messages: [],
      );
}
