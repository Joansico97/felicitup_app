import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'info_felicitup_event.dart';
part 'info_felicitup_state.dart';
part 'info_felicitup_bloc.freezed.dart';

class InfoFelicitupBloc extends Bloc<InfoFelicitupEvent, InfoFelicitupState> {
  InfoFelicitupBloc({
    required FelicitupRepository felicitupRepository,
  })  : _felicitupRepository = felicitupRepository,
        super(InfoFelicitupState.initial()) {
    on<InfoFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        sendFelicitup: (event) => _sendFelicitup(emit, event.felicitupId),
      ),
    );
  }

  final FelicitupRepository _felicitupRepository;

  _changeLoading(Emitter<InfoFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _sendFelicitup(Emitter<InfoFelicitupState> emit, String felicitupId) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _felicitupRepository.sendFelicitup(felicitupId);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
