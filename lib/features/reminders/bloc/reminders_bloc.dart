import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';

part 'reminders_event.dart';
part 'reminders_state.dart';
part 'reminders_bloc.freezed.dart';

class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  RemindersBloc({
    required ChatRepository chatRepository,
    required UserRepository userRepository,
  }) : _chatRepository = chatRepository,
       _userRepository = userRepository,
       super(RemindersState.initial()) {
    on<RemindersEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        createSingleChat:
            (event) => _createSingleChat(emit, event.singleChatData),
        deleteBirthdateAlert: (event) => _deleteBirthdateAlert(emit, event.id),
      ),
    );
  }

  final UserRepository _userRepository;
  final ChatRepository _chatRepository;

  _changeLoading(Emitter<RemindersState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _createSingleChat(
    Emitter<RemindersState> emit,
    SingleChatModel singleChatData,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _chatRepository.createSingleChat(singleChatData);
      return response.fold(
        (l) {
          logger.error(l);
          emit(state.copyWith(isLoading: false));
        },
        (r) {
          emit(state.copyWith(isLoading: false));
          if (rootNavigatorKey.currentContext!.mounted) {
            rootNavigatorKey.currentContext!.go(
              RouterPaths.singleChat,
              extra: SingleChatModel(
                chatId: r,
                userName: singleChatData.userName,
                userImage: singleChatData.userImage,
                friendId: singleChatData.friendId,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _deleteBirthdateAlert(Emitter<RemindersState> emit, String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.deleteReminder(id);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
