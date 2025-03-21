import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
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
    required FirebaseAuth firebaseAuth,
  })  : _felicitupRepository = felicitupRepository,
        _firebaseAuth = firebaseAuth,
        super(PeopleFelicitupState.initial()) {
    on<PeopleFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        informParticipation: (event) => _informParticipation(
          emit,
          event.felicitupId,
          event.newStatus,
        ),
        deleteParticipant: (event) => _deleteParticipant(
          emit,
          event.felicitupId,
          event.userId,
        ),
        startListening: (event) => _startListening(emit, event.felicitupId),
        recivedData: (event) => _recivedData(emit, event.invitedUsers),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<InvitedModel>>>? _invitedUsersSubscription;
  final FelicitupRepository _felicitupRepository;
  final FirebaseAuth _firebaseAuth;

  _changeLoading(Emitter<PeopleFelicitupState> emit) {
    emit(PeopleFelicitupState(isLoading: !state.isLoading));
  }

  _informParticipation(
    Emitter<PeopleFelicitupState> emit,
    String felicitupId,
    String newStatus,
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
            emit(state.copyWith(isLoading: false));
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
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
