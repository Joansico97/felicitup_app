import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'details_felicitup_dashboard_event.dart';
part 'details_felicitup_dashboard_state.dart';
part 'details_felicitup_dashboard_bloc.freezed.dart';

class DetailsFelicitupDashboardBloc extends Bloc<DetailsFelicitupDashboardEvent, DetailsFelicitupDashboardState> {
  DetailsFelicitupDashboardBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
  })  : _felicitupRepository = felicitupRepository,
        _userRepository = userRepository,
        super(DetailsFelicitupDashboardState.initial()) {
    on<DetailsFelicitupDashboardEvent>(
      (events, emit) => events.map(
        noEvent: (_) => _noEvent(),
        changeCurrentIndex: (event) => _changeCurrentIndex(emit, event.index),
        // getFelicitupInfo: (event) => _getFelicitupInfo(emit, event.felicitupId),
        asignCurrentChat: (event) => _asignCurrentChat(emit, event.chatId),
        startListening: (event) => _startListening(emit, event.felicitupId),
        recivedData: (event) => _recivedData(emit, event.felicitup),
      ),
    );
  }

  StreamSubscription<Either<ApiException, FelicitupModel>>? _felicitupSubscription;
  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;

  _noEvent() {}

  _changeCurrentIndex(Emitter<DetailsFelicitupDashboardState> emit, int index) {
    emit(state.copyWith(currentIndex: index));
  }

  _asignCurrentChat(Emitter<DetailsFelicitupDashboardState> emit, String chatId) async {
    try {
      await _userRepository.asignCurrentChatId(chatId);
    } catch (e) {
      logger.error('Error asignando el chat actual, $e');
    }
  }

  _startListening(Emitter<DetailsFelicitupDashboardState> emit, String felicitupId) {
    _felicitupSubscription = _felicitupRepository.streamSingleFelicitup(felicitupId).listen((either) {
      either.fold(
        (error) {},
        (feicitups) {
          add(DetailsFelicitupDashboardEvent.recivedData(feicitups));
        },
      );
    });
  }

  Future<void> _recivedData(Emitter<DetailsFelicitupDashboardState> emit, FelicitupModel listFelicitups) async {
    emit(state.copyWith(felicitup: listFelicitups));
  }

  @override
  Future<void> close() {
    _felicitupSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
