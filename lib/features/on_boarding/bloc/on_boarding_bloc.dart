import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'on_boarding_event.dart';
part 'on_boarding_state.dart';
part 'on_boarding_bloc.freezed.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  OnBoardingBloc() : super(OnBoardingState.initial()) {
    on<OnBoardingEvent>(
      (events, emit) => events.map(
        changeIndex: (_) => _changeIndex(emit),
        skipOnBoarding: (_) =>
            emit(state.copyWith(finishEnum: OnBoardingFinishEnum.finish)),
      ),
    );
  }

  void _changeIndex(Emitter<OnBoardingState> emit) {
    if (state.currentPage > 8) {
      emit(state.copyWith(finishEnum: OnBoardingFinishEnum.finish));
      return;
    }
    emit(state.copyWith(currentPage: state.currentPage + 1));
  }
}
