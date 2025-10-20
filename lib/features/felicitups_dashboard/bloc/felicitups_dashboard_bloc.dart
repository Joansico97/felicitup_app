import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';

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
        changeIndex: (event) => _changeIndex(emit, event.index),
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

  _changeIndex(Emitter<FelicitupsDashboardState> emit, int index) {
    emit(state.copyWith(currentIndex: index));
  }

  _sortPastFelicitups(
    Emitter<FelicitupsDashboardState> emit,
    int index,
    String userId,
  ) {
    switch (index) {
      case 0:
        emit(
          state.copyWith(listFelicitupsPast: state.backUpListFelicitupsPast),
        );
        break;
      case 1:
        final filteredList = state.backUpListFelicitupsPast
            .where(
              (felicitup) => felicitup.owner.any((data) => data.id == userId),
            )
            .toList();
        emit(state.copyWith(listFelicitupsPast: filteredList));
        break;
      case 2:
        final filteredList = state.backUpListFelicitupsPast
            .where(
              (felicitup) =>
                  felicitup.invitedUsers.any((data) => data == userId),
            )
            .toList();
        emit(state.copyWith(listFelicitupsPast: filteredList));
        break;
      default:
    }
  }

  _deleteFelicitup(
    Emitter<FelicitupsDashboardState> emit,
    String felicitupId,
    String chatId,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _felicitupRepository.deleteFelicitup(felicitupId);
      await _chatRepository.deleteChatDocument(chatId);

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _setLike(
    Emitter<FelicitupsDashboardState> emit,
    String felicitupId,
    String userId,
  ) async {
    unawaited(startLoadingModal());
    try {
      _felicitupRepository.setLike(felicitupId, userId);
      await stopLoadingModal();
    } catch (e) {
      await stopLoadingModal();
      unawaited(showErrorModal('Error al dar like'));
    }
  }

  _createSingleChat(
    Emitter<FelicitupsDashboardState> emit,
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

  _deleteBirthdateAlert(
    Emitter<FelicitupsDashboardState> emit,
    String id,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.deleteReminder(id);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _deletePastFelicitup(
    Emitter<FelicitupsDashboardState> emit,
    String felicitupId,
  ) async {
    final userId = _firebaseAuth.currentUser!.uid;
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _felicitupRepository.deleteAllPastFelicitups(felicitupId, userId);
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  _startListening(Emitter<FelicitupsDashboardState> emit) {
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

  _getRememberStatus(Emitter<FelicitupsDashboardState> emit) async {
    final data = await _localStorageHelper.read(
      key: LocalStorageConstants.userKey,
    );

    if (data == null) {
      await _localStorageHelper.write(
        key: LocalStorageConstants.userKey,
        value: jsonEncode('true'),
      );
      emit(state.copyWith(showSection: true));
    } else {
      emit(state.copyWith(showSection: data == 'true' ? true : false));
    }
  }

  _closeRememberSection(Emitter<FelicitupsDashboardState> emit) async {
    await _localStorageHelper.update(
      key: LocalStorageConstants.userKey,
      value: jsonEncode('false'),
    );
    emit(state.copyWith(showSection: false));
  }

  Future<void> _recivedData(
    Emitter<FelicitupsDashboardState> emit,
    List<FelicitupModel> listFelicitups,
  ) async {
    emit(state.copyWith(listFelicitups: listFelicitups));
  }

  Future<void> _recivedPastData(
    Emitter<FelicitupsDashboardState> emit,
    List<FelicitupModel> listFelicitups,
  ) async {
    emit(
      state.copyWith(
        listFelicitupsPast: listFelicitups,
        backUpListFelicitupsPast: listFelicitups,
      ),
    );
  }

  @override
  Future<void> close() {
    _felicitupSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    _felicitupPastSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
