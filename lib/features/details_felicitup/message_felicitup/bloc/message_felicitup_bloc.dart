import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_felicitup_event.dart';
part 'message_felicitup_state.dart';
part 'message_felicitup_bloc.freezed.dart';

class MessageFelicitupBloc extends Bloc<MessageFelicitupEvent, MessageFelicitupState> {
  MessageFelicitupBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
    required FirebaseFunctions firebaseFunctions,
  })  : _felicitupRepository = felicitupRepository,
        _userRepository = userRepository,
        _chatRepository = chatRepository,
        // _firebaseFunctions = firebaseFunctions,
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
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<ChatMessageModel>>>? _chatMessagesSubscription;
  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;
  final ChatRepository _chatRepository;
  // final FirebaseFunctions _firebaseFunctions;

  _loadMessages(Emitter<MessageFelicitupState> emit) {}

  _asignCurrentChat(Emitter<MessageFelicitupState> emit, String chatId) async {
    try {
      await _userRepository.asignCurrentChatId(chatId);
    } catch (e) {
      logger.error('Error asignando el chat actual, $e');
    }
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
          // await _firebaseFunctions
          //     .httpsCallable('testFunction') // Llama a la función de prueba.
          //     .call(
          //   {'testParam': 'Hola desde Flutter!'},
          // ); // Envía un parámetro simple.

          for (String id in ids) {
            await _userRepository.sendNotification(
              //   'testUserId', //  ¡Valores SIMPLES!
              //   'Test Title',
              //   'Test Message',
              //   'testChat',
              id,
              'Nuevo mensaje de $userName',
              chatMessage.message,
              felicitup.chatId,
              DataMessageModel(
                type: enumToPushMessageType(PushMessageType.chat),
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

  _startListening(Emitter<MessageFelicitupState> emit, String chatId) {
    _chatMessagesSubscription = _felicitupRepository.getChatMessages(chatId).listen((either) {
      either.fold(
        (error) {},
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
