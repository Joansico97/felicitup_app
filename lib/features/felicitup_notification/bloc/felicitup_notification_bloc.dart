import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/widgets/common/error_modal.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'felicitup_notification_event.dart';
part 'felicitup_notification_state.dart';
part 'felicitup_notification_bloc.freezed.dart';

class FelicitupNotificationBloc extends Bloc<FelicitupNotificationEvent, FelicitupNotificationState> {
  FelicitupNotificationBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
    required FirebaseAuth firebaseAuth,
  })  : _felicitupRepository = felicitupRepository,
        _userRepository = userRepository,
        _firebaseAuth = firebaseAuth,
        super(FelicitupNotificationState.initial()) {
    on<FelicitupNotificationEvent>(
      (events, emit) => events.map(
        noEvent: (_) => _noEvent(),
        changeLoading: (_) => _changeLoading(emit),
        getFelicitupData: (event) => _getFelicitupData(emit, event.felicitupId),
        getCreatorData: (event) => _getCreatorData(emit, event.userId),
        getInvitedUsersData: (event) => _getInvitedUsersData(emit, event.userIds),
        informParticipation: (event) => _informParticipation(emit, event.felicitupId, event.newStatus, event.userName),
        deleteParticipant: (event) => _deleteParticipant(emit, event.felicitupId, event.userId),
      ),
    );
  }

  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth;

  _noEvent() {}

  _changeLoading(Emitter<FelicitupNotificationState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _getFelicitupData(Emitter<FelicitupNotificationState> emit, String felicitupId) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _felicitupRepository.getFelicitupById(felicitupId);
      response.fold(
        (l) async {
          emit(state.copyWith(isLoading: false));
          await showErrorModal(l.message);
        },
        (r) {
          add(FelicitupNotificationEvent.getCreatorData(r.createdBy));
          add(FelicitupNotificationEvent.getInvitedUsersData(r.invitedUsers));
          emit(state.copyWith(
            isLoading: false,
            currentFelicitup: r,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      await showErrorModal('Error al obtener la información de la felicitup');
    }
  }

  _getCreatorData(Emitter<FelicitupNotificationState> emit, String userId) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _userRepository.getUserData(state.currentFelicitup?.createdBy ?? '');
      response.fold(
        (l) async {
          emit(state.copyWith(isLoading: false));
          await showErrorModal(l.message);
        },
        (r) {
          emit(state.copyWith(
            isLoading: false,
            creator: UserModel.fromJson(r),
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      await showErrorModal('Error al obtener la información del creador');
    }
  }

  _getInvitedUsersData(Emitter<FelicitupNotificationState> emit, List<String> ids) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _userRepository.getListUserData(state.currentFelicitup?.invitedUsers ?? []);
      response.fold(
        (l) async {
          emit(state.copyWith(isLoading: false));
          await showErrorModal(l.message);
        },
        (r) {
          emit(state.copyWith(
            isLoading: false,
            invitedUsers: List<UserModel>.from(r.map((e) => UserModel.fromJson(e))),
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      await showErrorModal('Error al obtener la información de los usuarios invitados');
    }
  }

  _informParticipation(
    Emitter<FelicitupNotificationState> emit,
    String felicitupId,
    String newStatus,
    String userNmae,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _felicitupRepository.setParticipation(felicitupId, newStatus);

      return response.fold(
        (error) {
          emit(state.copyWith(isLoading: false));
          unawaited(showErrorModal(error.message));
        },
        (data) async {
          if (newStatus == enumToStringAssistance(AssistanceStatus.rejected)) {
            add(FelicitupNotificationEvent.deleteParticipant(felicitupId, _firebaseAuth.currentUser!.uid));
            await _userRepository.sendNotification(
              userId: state.currentFelicitup?.createdBy ?? '',
              title: 'Rechazo de participación',
              message: '$userNmae ha informado que no participará en la felicitup',
              currentChat: '',
              data: DataMessageModel(
                type: enumToPushMessageType(PushMessageType.participation),
                felicitupId: felicitupId,
                chatId: '',
                name: '',
                friendId: '',
                userImage: '',
              ),
            );
          } else {
            await _userRepository.sendNotification(
              userId: state.currentFelicitup?.createdBy ?? '',
              title: 'Información de confirmación de asistencia',
              message: '$userNmae ha informado que participará en la felicitup',
              currentChat: '',
              data: DataMessageModel(
                type: enumToPushMessageType(PushMessageType.participation),
                felicitupId: felicitupId,
                chatId: '',
                name: '',
                friendId: '',
                userImage: '',
              ),
            );
            emit(state.copyWith(isLoading: false));
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _deleteParticipant(Emitter<FelicitupNotificationState> emit, String felicitupId, String userId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _felicitupRepository.deleteParticipant(felicitupId, userId);
      response.fold(
        (error) {
          emit(state.copyWith(isLoading: false));
          unawaited(showErrorModal(error.message));
        },
        (data) => emit(state.copyWith(isLoading: false)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
