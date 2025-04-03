part of 'single_chat_bloc.dart';

@freezed
class SingleChatState with _$SingleChatState {
  const factory SingleChatState({
    required bool isLoading,
    required String currentChatId,
    required List<ChatMessageModel> messages,
  }) = _SingleChatState;

  factory SingleChatState.initial() => SingleChatState(
        isLoading: false,
        currentChatId: '',
        messages: [],
      );
}
