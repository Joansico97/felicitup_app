import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'frequent_questions_event.dart';
part 'frequent_questions_state.dart';
part 'frequent_questions_bloc.freezed.dart';

class FrequentQuestionsBloc
    extends Bloc<FrequentQuestionsEvent, FrequentQuestionsState> {
  FrequentQuestionsBloc() : super(FrequentQuestionsState.initial()) {
    on<FrequentQuestionsEvent>(
      (events, emit) => events.map(changeLoading: (_) => changeLoading(emit)),
    );
  }

  changeLoading(Emitter<FrequentQuestionsState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
