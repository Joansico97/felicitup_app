part of 'list_single_chat_bloc.dart';

@freezed
abstract class ListSingleChatState with _$ListSingleChatState {
  const factory ListSingleChatState({
    required List<ChatMessageModel> singleChats,
    required bool isLoading,
    required String errorMessage,
  }) = _ListSingleChatState;

  factory ListSingleChatState.initial() =>
      ListSingleChatState(singleChats: [], isLoading: false, errorMessage: '');
}
