import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bote_felicitup_event.dart';
part 'bote_felicitup_state.dart';
part 'bote_felicitup_bloc.freezed.dart';

class BoteFelicitupBloc extends Bloc<BoteFelicitupEvent, BoteFelicitupState> {
  BoteFelicitupBloc({
    required FelicitupRepository felicitupRepository,
  })  : _felicitupRepository = felicitupRepository,
        super(BoteFelicitupState.initial()) {
    on<BoteFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        startListening: (event) => _startListening(emit, event.felicitupId),
        recivedData: (event) => _recivedData(emit, event.invitedUsers),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<InvitedModel>>>? _invitedUsersSubscription;
  final FelicitupRepository _felicitupRepository;

  _changeLoading(Emitter<BoteFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _startListening(Emitter<BoteFelicitupState> emit, String felicitupId) {
    _invitedUsersSubscription = _felicitupRepository.getInvitedStream(felicitupId).listen((either) {
      either.fold(
        (error) {},
        (feicitups) {
          add(BoteFelicitupEvent.recivedData(feicitups));
        },
      );
    });
  }

  Future<void> _recivedData(Emitter<BoteFelicitupState> emit, List<InvitedModel> listUsers) async {
    emit(state.copyWith(invitedUsers: listUsers));
  }

  @override
  Future<void> close() {
    _invitedUsersSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
