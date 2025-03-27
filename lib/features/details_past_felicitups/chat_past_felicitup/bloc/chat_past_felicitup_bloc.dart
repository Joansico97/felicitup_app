import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/utils/logger.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_past_felicitup_event.dart';
part 'chat_past_felicitup_state.dart';
part 'chat_past_felicitup_bloc.freezed.dart';

class ChatPastFelicitupBloc extends Bloc<ChatPastFelicitupEvent, ChatPastFelicitupState> {
  ChatPastFelicitupBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
  })  : _felicitupRepository = felicitupRepository,
        _userRepository = userRepository,
        _chatRepository = chatRepository,
        super(ChatPastFelicitupState.initial()) {
    on<ChatPastFelicitupEvent>(
      (events, emit) => events.map(
        asignCurrentChat: (event) => _asignCurrentChat(emit, event.chatId),
        sendMessage: (event) => _sendMessage(
          emit,
          event.chatMessage,
          event.felicitup,
          event.userId,
          event.userName,
        ),
        startListening: (event) => _startListening(emit, event.chatId),
        recivedData: (event) => _recivedData(emit, event.listMessages),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<ChatMessageModel>>>? _chatMessagesSubscription;
  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;
  final ChatRepository _chatRepository;

  _asignCurrentChat(Emitter<ChatPastFelicitupState> emit, String chatId) async {
    try {
      await _userRepository.asignCurrentChatId(chatId);
    } catch (e) {
      logger.error('Error asignando el chat actual, $e');
    }
  }

  _sendMessage(
    Emitter<ChatPastFelicitupState> emit,
    ChatMessageModel chatMessage,
    FelicitupModel felicitup,
    String userId,
    String userName,
  ) async {
    try {
      final response = await _chatRepository.sendMessage(felicitup.chatId, chatMessage);

      response.fold(
        (l) {},
        (r) async {
          List<String> ids = [...felicitup.invitedUsers];
          ids.remove(userId);

          for (String id in ids) {
            await _userRepository.sendNotification(
              userId: id,
              title: 'Nuevo mensaje de $userName',
              message: chatMessage.message,
              currentChat: felicitup.chatId,
              data: DataMessageModel(
                type: enumToPushMessageType(PushMessageType.past),
                felicitupId: felicitup.id,
                chatId: felicitup.chatId,
                name: '',
              ),
            );
          }
        },
      );
    } catch (e) {
      logger.error('Error enviando el mensaje, $e');
    }
  }

  _startListening(Emitter<ChatPastFelicitupState> emit, String chatId) {
    _chatMessagesSubscription = _felicitupRepository.getChatMessages(chatId).listen((either) {
      either.fold(
        (error) {},
        (messages) {
          add(ChatPastFelicitupEvent.recivedData(messages));
        },
      );
    });
  }

  Future<void> _recivedData(Emitter<ChatPastFelicitupState> emit, List<ChatMessageModel> listMessages) async {
    emit(state.copyWith(messages: listMessages));
  }

  @override
  Future<void> close() {
    _chatMessagesSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
