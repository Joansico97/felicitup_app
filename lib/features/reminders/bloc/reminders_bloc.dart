import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminders_event.dart';
part 'reminders_state.dart';
part 'reminders_bloc.freezed.dart';

class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  RemindersBloc() : super(RemindersState.initial()) {
    on<RemindersEvent>((events, emit) => events.map(changeLoading: (_) => _changeLoading(emit)));
  }

  _changeLoading(Emitter<RemindersState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
