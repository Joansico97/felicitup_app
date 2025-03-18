import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bote_felicitup_event.dart';
part 'bote_felicitup_state.dart';
part 'bote_felicitup_bloc.freezed.dart';

class BoteFelicitupBloc extends Bloc<BoteFelicitupEvent, BoteFelicitupState> {
  BoteFelicitupBloc() : super(BoteFelicitupState.initial()) {
    on<BoteFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<BoteFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
