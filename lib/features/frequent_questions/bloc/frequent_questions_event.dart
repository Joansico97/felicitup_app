part of 'frequent_questions_bloc.dart';

@freezed
class FrequentQuestionsEvent with _$FrequentQuestionsEvent {
  const factory FrequentQuestionsEvent.changeLoading() = _changeLoading;
}
