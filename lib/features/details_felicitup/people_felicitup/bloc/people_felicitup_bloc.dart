import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'people_felicitup_event.dart';
part 'people_felicitup_state.dart';
part 'people_felicitup_bloc.freezed.dart';

class PeopleFelicitupBloc extends Bloc<PeopleFelicitupEvent, PeopleFelicitupState> {
  PeopleFelicitupBloc() : super(PeopleFelicitupState.initial()) {
    on<PeopleFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<PeopleFelicitupState> emit) {
    emit(PeopleFelicitupState(isLoading: !state.isLoading));
  }
}
