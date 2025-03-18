part of 'message_felicitup_bloc.dart';

@freezed
class MessageFelicitupState with _$MessageFelicitupState {
  const factory MessageFelicitupState({
    required bool isLoading,
    required List<ChatMessageModel> messages,
  }) = _MessageFelicitupState;

  factory MessageFelicitupState.initial() => MessageFelicitupState(
        isLoading: false,
        messages: [],
      );
}
