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
import 'package:flutter/material.dart';
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
        changeLoading: (_) => _changeLoading(emit),
        deleteFelicitup:
            (event) => _deleteFelicitup(emit, event.felicitupId, event.chatId),
        changeListBoolsTap:
            (event) => _changeListBoolTap(emit, event.index, event.controller),
        setLike: (event) => _setLike(emit, event.felicitupId, event.userId),
        updateMatchList: (event) => _updateMatchList(event.phones),
        createSingleChat:
            (event) => _createSingleChat(emit, event.singleChatData),
        getRememberStatus: (_) => _getRememberStatus(emit),
        closeRememberSection: (_) => _closeRememberSection(emit),
        deleteBirthdateAlert: (event) => _deleteBirthdateAlert(emit, event.id),
        startListening: (_) => _startListening(emit),
        recivedData: (event) => _recivedData(emit, event.listFelicitups),
        recivedPastData:
            (event) => _recivedPastData(emit, event.listFelicitups),
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

  _changeLoading(Emitter<FelicitupsDashboardState> emit) {}

  _changeListBoolTap(
    Emitter<FelicitupsDashboardState> emit,
    int index,
    PageController controller,
  ) {
    final listBoolsTap = state.listBoolsTap.map((e) => false).toList();
    listBoolsTap[index] = true;
    emit(state.copyWith(listBoolsTap: listBoolsTap));
    controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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

  _updateMatchList(List<String> phonesList) async {
    List<String> phones = [...phonesList];

    final response = await _userRepository.getListUserDataByPhone(phones);

    response.fold((l) => logger.error(l), (r) async {
      List<String> ids = [];
      for (final doc in r) {
        if (doc.id != null) {
          ids.add(doc.id!);
        }
      }
      await _userRepository.updateMatchList(ids);
    });
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

  _startListening(Emitter<FelicitupsDashboardState> emit) {
    final userId = _firebaseAuth.currentUser!.uid;
    _felicitupSubscription = _felicitupRepository
        .streamFelicitups(userId)
        .listen((either) {
          either.fold((error) {}, (feicitups) {
            add(FelicitupsDashboardEvent.recivedData(feicitups));
          });
        });
    _felicitupPastSubscription = _felicitupRepository
        .streamPastFelicitups(userId)
        .listen((either) {
          either.fold((error) {}, (feicitups) {
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
    emit(state.copyWith(listFelicitupsPast: listFelicitups));
  }

  @override
  Future<void> close() {
    _felicitupSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    _felicitupPastSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
