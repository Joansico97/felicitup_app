import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/repositories/repositories.dart';

part 'people_past_felicitup_event.dart';
part 'people_past_felicitup_state.dart';
part 'people_past_felicitup_bloc.freezed.dart';

class PeoplePastFelicitupBloc extends Bloc<PeoplePastFelicitupEvent, PeoplePastFelicitupState> {
  PeoplePastFelicitupBloc({
    required FelicitupRepository felicitupRepository,
  })  : _felicitupRepository = felicitupRepository,
        super(PeoplePastFelicitupState.initial()) {
    on<PeoplePastFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        startListening: (event) => _startListening(emit, event.felicitupId),
        recivedData: (event) => _recivedData(emit, event.invitedUsers),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<InvitedModel>>>? _invitedUsersSubscription;
  final FelicitupRepository _felicitupRepository;

  _changeLoading(Emitter<PeoplePastFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _startListening(Emitter<PeoplePastFelicitupState> emit, String felicitupId) {
    _invitedUsersSubscription = _felicitupRepository.getInvitedStream(felicitupId).listen((either) {
      either.fold(
        (error) {},
        (listUsers) {
          add(PeoplePastFelicitupEvent.recivedData(listUsers));
        },
      );
    });
  }

  Future<void> _recivedData(Emitter<PeoplePastFelicitupState> emit, List<InvitedModel> listUsers) async {
    emit(state.copyWith(invitedUsers: listUsers));
  }

  @override
  Future<void> close() {
    _invitedUsersSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
