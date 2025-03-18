import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'info_felicitup_event.dart';
part 'info_felicitup_state.dart';
part 'info_felicitup_bloc.freezed.dart';

class InfoFelicitupBloc extends Bloc<InfoFelicitupEvent, InfoFelicitupState> {
  InfoFelicitupBloc() : super(InfoFelicitupState.initial()) {
    on<InfoFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<InfoFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
