import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'people_felicitup_event.dart';
part 'people_felicitup_state.dart';
part 'people_felicitup_bloc.freezed.dart';

class PeopleFelicitupBloc extends Bloc<PeopleFelicitupEvent, PeopleFelicitupState> {
  PeopleFelicitupBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
    required FirebaseAuth firebaseAuth,
  })  : _felicitupRepository = felicitupRepository,
        _userRepository = userRepository,
        _firebaseAuth = firebaseAuth,
        super(PeopleFelicitupState.initial()) {
    on<PeopleFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        loadFriendsData: (event) => _loadFriendsData(emit, event.usersIds),
        informParticipation: (event) => _informParticipation(
          emit,
          event.felicitupId,
          event.newStatus,
          event.name,
          event.felicitupOwnerId,
        ),
        sendNotification: (event) => _sendNotification(
          event.userId,
          event.name,
          event.felicitupId,
        ),
        deleteParticipant: (event) => _deleteParticipant(
          emit,
          event.felicitupId,
          event.userId,
        ),
        addParticipant: (event) => _addParticipant(emit, event.participant),
        updateParticipantsList: (event) => _updateParticipantsList(emit, event.felicitupId),
        startListening: (event) => _startListening(emit, event.felicitupId),
        recivedData: (event) => _recivedData(emit, event.invitedUsers),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<InvitedModel>>>? _invitedUsersSubscription;
  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth;

  _changeLoading(Emitter<PeopleFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _informParticipation(
    Emitter<PeopleFelicitupState> emit,
    String felicitupId,
    String felicitupOwnerId,
    String newStatus,
    String name,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _felicitupRepository.setParticipation(felicitupId, newStatus);
      response.fold(
        (error) {
          emit(state.copyWith(isLoading: false));
          unawaited(showErrorModal(error.message));
        },
        (data) async {
          if (newStatus == enumToStringAssistance(AssistanceStatus.rejected)) {
            add(PeopleFelicitupEvent.deleteParticipant(felicitupId, _firebaseAuth.currentUser!.uid));
          } else {
            add(PeopleFelicitupEvent.sendNotification(
              felicitupOwnerId,
              name,
              felicitupId,
            ));
            emit(state.copyWith(isLoading: false));
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _addParticipant(Emitter<PeopleFelicitupState> emit, InvitedModel participant) {
    final List<InvitedModel> participants = [...state.invitedContacts];

    if (participants.contains(participant)) {
      participants.remove(participant);
    } else {
      participants.add(participant);
    }
    emit(state.copyWith(invitedContacts: participants));
  }

  _updateParticipantsList(Emitter<PeopleFelicitupState> emit, String felicitupId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _felicitupRepository.updateFelicitupParticipants(felicitupId, state.invitedContacts);

      response.fold(
        (error) {
          emit(state.copyWith(isLoading: false));
          logger.error(error);
          // unawaited(showErrorModal(error.message));
        },
        (data) {
          emit(state.copyWith(isLoading: false));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _loadFriendsData(Emitter<PeopleFelicitupState> emit, List<String> usersIds) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _userRepository.getListUserData(usersIds);
      response.fold(
        (error) {
          logger.error(error);
          emit(state.copyWith(isLoading: false));
        },
        (users) {
          List<UserModel> usersList = [];
          for (final data in users) {
            usersList.add(UserModel.fromJson(data));
          }
          emit(state.copyWith(isLoading: false, friendList: usersList));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _sendNotification(String userId, String name, String felicitupId) async {
    await _userRepository.sendNotification(
      userId,
      'Información de confirmación de asistencia',
      '$name ha informado que participará en la felicitup',
      '',
      DataMessageModel(
        type: enumToPushMessageType(PushMessageType.participation),
        felicitupId: felicitupId,
        chatId: '',
        name: '',
      ),
    );
  }

  _deleteParticipant(Emitter<PeopleFelicitupState> emit, String felicitupId, String userId) async {
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

  _startListening(Emitter<PeopleFelicitupState> emit, String felicitupId) {
    _invitedUsersSubscription = _felicitupRepository.getInvitedStream(felicitupId).listen((either) {
      either.fold(
        (error) {},
        (feicitups) {
          add(PeopleFelicitupEvent.recivedData(feicitups));
        },
      );
    });
  }

  Future<void> _recivedData(Emitter<PeopleFelicitupState> emit, List<InvitedModel> listUsers) async {
    emit(state.copyWith(invitedUsers: listUsers));
  }

  @override
  Future<void> close() {
    _invitedUsersSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
