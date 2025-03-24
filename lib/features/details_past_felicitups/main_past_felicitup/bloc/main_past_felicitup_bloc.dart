import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_past_felicitup_event.dart';
part 'main_past_felicitup_state.dart';
part 'main_past_felicitup_bloc.freezed.dart';

class MainPastFelicitupBloc extends Bloc<MainPastFelicitupEvent, MainPastFelicitupState> {
  MainPastFelicitupBloc() : super(MainPastFelicitupState.initial()) {
    on<MainPastFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<MainPastFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
