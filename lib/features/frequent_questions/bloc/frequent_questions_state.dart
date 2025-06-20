part of 'frequent_questions_bloc.dart';

@freezed
class FrequentQuestionsState with _$FrequentQuestionsState {
  const factory FrequentQuestionsState({required bool isLoading}) =
      _FrequentQuestionsState;

  factory FrequentQuestionsState.initial() =>
      FrequentQuestionsState(isLoading: false);
}
