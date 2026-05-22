import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'felicitups_dashboard_event.dart';
part 'felicitups_dashboard_state.dart';
part 'felicitups_dashboard_bloc.freezed.dart';

class FelicitupsDashboardBloc
    extends Bloc<FelicitupsDashboardEvent, FelicitupsDashboardState> {
  FelicitupsDashboardBloc({
    required FelicitupRepository felicitupRepository,
    required ChatRepository chatRepository,
    required UserRepository userRepository,
    required FirebaseAuth firebaseAuth,
    required LocalStorageHelper localStorageHelper,
  }) : _felicitupRepository = felicitupRepository,
       _chatRepository = chatRepository,
       _userRepository = userRepository,
       _firebaseAuth = firebaseAuth,
       _localStorageHelper = localStorageHelper,
       super(FelicitupsDashboardState.initial()) {
    on<FelicitupsDashboardEvent>(
      (events, emit) => events.map(
        changeIndex: (event) => emit(state.copyWith(
          currentIndex: event.index,
          status: FelicitupsDashboardStatus.initial,
        )),
        sortPastFelicitups: (event) =>
            _sortPastFelicitups(emit, event.index, event.userId),
        deleteFelicitup: (event) =>
            _deleteFelicitup(emit, event.felicitupId, event.chatId),
        setLike: (event) => _setLike(emit, event.felicitupId, event.userId),
        createSingleChat: (event) =>
            _createSingleChat(emit, event.singleChatData),
        getRememberStatus: (_) => _getRememberStatus(emit),
        closeRememberSection: (_) => _closeRememberSection(emit),
        deleteBirthdateAlert: (event) => _deleteBirthdateAlert(emit, event.id),
        startListening: (_) => _startListening(emit),
        recivedData: (event) => _recivedData(emit, event.listFelicitups),
        recivedPastData: (event) =>
            _recivedPastData(emit, event.listFelicitups),
        deletePastFelicitup: (event) =>
            _deletePastFelicitup(emit, event.felicitupId),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<FelicitupModel>>>?
  _felicitupSubscription;
  StreamSubscription<Either<ApiException, List<FelicitupModel>>>?
  _felicitupPastSubscription;
  final FelicitupRepository _felicitupRepository;
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth;
  final LocalStorageHelper _localStorageHelper;

  void _sortPastFelicitups(
    Emitter<FelicitupsDashboardState> emit,
    int index,
    String userId,
  ) {
    switch (index) {
      case 0:
        emit(
          state.copyWith(
            listFelicitupsPast: state.backUpListFelicitupsPast,
            status: FelicitupsDashboardStatus.initial,
          ),
        );
        break;
      case 1:
        final filteredList = state.backUpListFelicitupsPast
            .where(
              (felicitup) => felicitup.owner.any((data) => data.id == userId),
            )
            .toList();
        emit(state.copyWith(
          listFelicitupsPast: filteredList,
          status: FelicitupsDashboardStatus.initial,
        ));
        break;
      case 2:
        final filteredList = state.backUpListFelicitupsPast
            .where(
              (felicitup) =>
                  felicitup.invitedUsers.any((data) => data == userId),
            )
            .toList();
        emit(state.copyWith(
          listFelicitupsPast: filteredList,
          status: FelicitupsDashboardStatus.initial,
        ));
        break;
      default:
    }
  }

  Future<void> _deleteFelicitup(
    Emitter<FelicitupsDashboardState> emit,
    String felicitupId,
    String chatId,
  ) async {
    emit(state.copyWith(isLoading: true, status: FelicitupsDashboardStatus.loading));
    try {
      await _felicitupRepository.deleteFelicitup(felicitupId);
      await _chatRepository.deleteChatDocument(chatId);

      emit(state.copyWith(isLoading: false, status: FelicitupsDashboardStatus.success));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        status: FelicitupsDashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _setLike(
    Emitter<FelicitupsDashboardState> emit,
    String felicitupId,
    String userId,
  ) async {
    emit(state.copyWith(isLoading: true, status: FelicitupsDashboardStatus.loading));
    try {
      final response = await _felicitupRepository.setLike(felicitupId, userId);
      response.fold(
        (l) {
          emit(state.copyWith(
            isLoading: false,
            status: FelicitupsDashboardStatus.likeError,
            errorMessage: l.message,
          ));
        },
        (r) {
          emit(state.copyWith(
            isLoading: false,
            status: FelicitupsDashboardStatus.likeSuccess,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        status: FelicitupsDashboardStatus.likeError,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _createSingleChat(
    Emitter<FelicitupsDashboardState> emit,
    SingleChatModel singleChatData,
  ) async {
    emit(state.copyWith(isLoading: true, status: FelicitupsDashboardStatus.loading));
    try {
      final response = await _chatRepository.createSingleChat(singleChatData);
      response.fold(
        (l) {
          logger.error(l);
          emit(state.copyWith(
            isLoading: false,
            status: FelicitupsDashboardStatus.error,
            errorMessage: l.message,
          ));
        },
        (r) {
          final newChat = SingleChatModel(
            chatId: r,
            userName: singleChatData.userName,
            userImage: singleChatData.userImage,
            friendId: singleChatData.friendId,
          );
          emit(state.copyWith(
            isLoading: false,
            status: FelicitupsDashboardStatus.chatCreated,
            createdChat: newChat,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        status: FelicitupsDashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _deleteBirthdateAlert(
    Emitter<FelicitupsDashboardState> emit,
    String id,
  ) async {
    emit(state.copyWith(isLoading: true, status: FelicitupsDashboardStatus.loading));
    try {
      await _userRepository.deleteReminder(id);
      emit(state.copyWith(isLoading: false, status: FelicitupsDashboardStatus.success));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        status: FelicitupsDashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _deletePastFelicitup(
    Emitter<FelicitupsDashboardState> emit,
    String felicitupId,
  ) async {
    final userId = _firebaseAuth.currentUser!.uid;
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      status: FelicitupsDashboardStatus.loading,
    ));

    try {
      await _felicitupRepository.deleteAllPastFelicitups(felicitupId, userId);
      emit(state.copyWith(isLoading: false, status: FelicitupsDashboardStatus.success));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        status: FelicitupsDashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _startListening(Emitter<FelicitupsDashboardState> emit) {
    final userId = _firebaseAuth.currentUser!.uid;
    _felicitupSubscription = _felicitupRepository
        .streamFelicitups(userId)
        .listen((either) {
          either.fold((_) {}, (feicitups) {
            add(FelicitupsDashboardEvent.recivedData(feicitups));
          });
        });
    _felicitupPastSubscription = _felicitupRepository
        .streamPastFelicitups(userId)
        .listen((either) {
          either.fold((_) {}, (feicitups) {
            add(FelicitupsDashboardEvent.recivedPastData(feicitups));
          });
        });
  }

  Future<void> _getRememberStatus(
    Emitter<FelicitupsDashboardState> emit,
  ) async {
    final data = await _localStorageHelper.read(
      key: LocalStorageConstants.userKey,
    );

    if (data == null) {
      await _localStorageHelper.write(
        key: LocalStorageConstants.userKey,
        value: jsonEncode('true'),
      );
      emit(state.copyWith(showSection: true, status: FelicitupsDashboardStatus.initial));
    } else {
      emit(state.copyWith(
        showSection: data == 'true' ? true : false,
        status: FelicitupsDashboardStatus.initial,
      ));
    }
  }

  Future<void> _closeRememberSection(
    Emitter<FelicitupsDashboardState> emit,
  ) async {
    await _localStorageHelper.update(
      key: LocalStorageConstants.userKey,
      value: jsonEncode('false'),
    );
    emit(state.copyWith(showSection: false, status: FelicitupsDashboardStatus.initial));
  }

  Future<void> _recivedData(
    Emitter<FelicitupsDashboardState> emit,
    List<FelicitupModel> listFelicitups,
  ) async {
    emit(state.copyWith(
      listFelicitups: listFelicitups,
      status: FelicitupsDashboardStatus.initial,
    ));
  }

  Future<void> _recivedPastData(
    Emitter<FelicitupsDashboardState> emit,
    List<FelicitupModel> listFelicitups,
  ) async {
    emit(
      state.copyWith(
        listFelicitupsPast: listFelicitups,
        backUpListFelicitupsPast: listFelicitups,
        status: FelicitupsDashboardStatus.initial,
      ),
    );
  }

  @override
  Future<void> close() {
    _felicitupSubscription?.cancel();
    _felicitupPastSubscription?.cancel();
    return super.close();
  }
}
