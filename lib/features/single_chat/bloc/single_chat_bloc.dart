import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'single_chat_event.dart';
part 'single_chat_state.dart';
part 'single_chat_bloc.freezed.dart';

class SingleChatBloc extends Bloc<SingleChatEvent, SingleChatState> {
  SingleChatBloc({
    required ChatRepository chatRepository,
    required UserRepository userRepository,
  })  : _chatRepository = chatRepository,
        _userRepository = userRepository,
        super(SingleChatState.initial()) {
    on<SingleChatEvent>(
      (events, emit) => events.map(
        changeIsLoading: (_) => _changeIsLoading(emit),
        setCurrentChatId: (event) => _setCurrentChatId(emit, event.chatId),
        sendMessage: (event) => _sendMessage(
          emit,
          event.chatMessage,
          event.chatId,
          event.userId,
          event.userName,
          event.userImage,
        ),
        startListening: (event) => _startListening(emit, event.chatId),
        recivedData: (event) => _recivedData(emit, event.listMessages),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<ChatMessageModel>>>? _chatMessagesSubscription;
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;

  _changeIsLoading(Emitter<SingleChatState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _setCurrentChatId(Emitter<SingleChatState> emit, String chatId) async {
    emit(state.copyWith(currentChatId: chatId));
  }

  _sendMessage(
    Emitter<SingleChatState> emit,
    ChatMessageModel chatMessage,
    String chatId,
    String userId,
    String userName,
    String userImage,
  ) async {
    final response = await _chatRepository.sendMessageSingleChat(chatId, chatMessage);

    response.fold(
      (l) {},
      (r) async {
        await _userRepository.sendNotification(
          userId: userId,
          title: 'Nuevo mensaje de $userName',
          message: chatMessage.message,
          currentChat: chatId,
          data: DataMessageModel(
            type: enumToPushMessageType(PushMessageType.chat),
            felicitupId: '',
            chatId: chatId,
            name: userName,
            friendId: userId,
            userImage: userImage,
          ),
        );
      },
    );
  }

  _startListening(Emitter<SingleChatState> emit, String chatId) {
    _chatMessagesSubscription = _chatRepository.getChatMessages(chatId).listen((either) {
      either.fold(
        (error) {
          FirebaseCrashlytics.instance.recordError(
            error,
            StackTrace.current,
            reason: 'Error al obtener los mensajes del chat',
          );
        },
        (feicitups) {
          add(SingleChatEvent.recivedData(feicitups));
        },
      );
    });
  }

  Future<void> _recivedData(Emitter<SingleChatState> emit, List<ChatMessageModel> listMessages) async {
    emit(state.copyWith(messages: listMessages));
  }

  @override
  Future<void> close() {
    _chatMessagesSubscription?.cancel();
    return super.close();
  }
}
