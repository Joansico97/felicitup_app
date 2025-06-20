import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash_event.dart';
part 'splash_state.dart';
part 'splash_bloc.freezed.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashState.initial()) {
    on<SplashEvent>(
      (events, emit) => events.map(changeLoading: (_) => _changeLoading(emit)),
    );
  }

  _changeLoading(Emitter<SplashState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
