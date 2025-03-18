import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial()) {
    on<HomeEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        changeCreate: (_) => _changeCreate(emit),
        changeShowButton: (_) => _changeShowButton(emit),
      ),
    );
  }

  _changeLoading(Emitter<HomeState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _changeCreate(Emitter<HomeState> emit) {
    emit(state.copyWith(create: !state.create));
  }

  _changeShowButton(Emitter<HomeState> emit) {
    emit(state.copyWith(showButton: !state.showButton));
  }
}
