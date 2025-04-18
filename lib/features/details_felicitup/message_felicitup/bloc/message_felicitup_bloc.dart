import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_felicitup_event.dart';
part 'message_felicitup_state.dart';
part 'message_felicitup_bloc.freezed.dart';

class MessageFelicitupBloc extends Bloc<MessageFelicitupEvent, MessageFelicitupState> {
  MessageFelicitupBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
  })  : _felicitupRepository = felicitupRepository,
        _userRepository = userRepository,
        _chatRepository = chatRepository,
        super(MessageFelicitupState.initial()) {
    on<MessageFelicitupEvent>(
      (events, emit) => events.map(
        loadMessages: (_) => _loadMessages(emit),
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
        setCurrentChatId: (event) => _setCurrentChatId(emit, event.chatId),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<ChatMessageModel>>>? _chatMessagesSubscription;
  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;
  final ChatRepository _chatRepository;

  _loadMessages(Emitter<MessageFelicitupState> emit) {}

  _asignCurrentChat(Emitter<MessageFelicitupState> emit, String chatId) async {
    try {
      await _userRepository.asignCurrentChatId(chatId);
    } catch (e) {
      logger.error('Error asignando el chat actual, $e');
    }
  }

  _setCurrentChatId(Emitter<MessageFelicitupState> emit, String chatId) async {
    emit(state.copyWith(currentChatId: chatId));
  }

  _sendMessage(
    Emitter<MessageFelicitupState> emit,
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
                type: enumToPushMessageType(PushMessageType.chat),
                felicitupId: felicitup.id,
                chatId: felicitup.chatId,
                name: '',
                friendId: '',
                userImage: '',
              ),
            );
          }
        },
      );
    } catch (e) {
      logger.error('Error enviando el mensaje, $e');
    }
  }

  _startListening(Emitter<MessageFelicitupState> emit, String chatId) {
    _chatMessagesSubscription = _felicitupRepository.getChatMessages(chatId).listen((either) {
      either.fold(
        (error) {
          FirebaseCrashlytics.instance.recordError(
            error,
            StackTrace.current,
            reason: 'Error al obtener los mensajes del chat',
          );
        },
        (feicitups) {
          add(MessageFelicitupEvent.recivedData(feicitups));
        },
      );
    });
  }

  Future<void> _recivedData(Emitter<MessageFelicitupState> emit, List<ChatMessageModel> listMessages) async {
    emit(state.copyWith(messages: listMessages));
  }

  @override
  Future<void> close() {
    _chatMessagesSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
