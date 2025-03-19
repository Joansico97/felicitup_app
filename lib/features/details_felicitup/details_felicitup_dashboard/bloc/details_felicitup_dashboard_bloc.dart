import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
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
        getFelicitupInfo: (event) => _getFelicitupInfo(emit, event.felicitupId),
        asignCurrentChat: (event) => _asignCurrentChat(emit, event.chatId),
      ),
    );
  }

  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;

  _noEvent() {}

  _changeCurrentIndex(Emitter<DetailsFelicitupDashboardState> emit, int index) {
    emit(state.copyWith(currentIndex: index));
  }

  _getFelicitupInfo(Emitter<DetailsFelicitupDashboardState> emit, String felicitupId) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _felicitupRepository.getFelicitupById(felicitupId);
      response.fold(
        (l) async {
          emit(state.copyWith(isLoading: false));
          await showErrorModal(l.message);
        },
        (r) {
          emit(state.copyWith(
            isLoading: false,
            felicitup: r,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      await showErrorModal('Error al obtener la información de la felicitup');
    }
  }

  _asignCurrentChat(Emitter<DetailsFelicitupDashboardState> emit, String chatId) async {
    try {
      await _userRepository.asignCurrentChatId(chatId);
    } catch (e) {
      logger.error('Error asignando el chat actual, $e');
    }
  }
}
