part of 'on_boarding_bloc.dart';

@freezed
class OnBoardingEvent with _$OnBoardingEvent {
  const factory OnBoardingEvent.changeIndex() = _changeIndex;
  const factory OnBoardingEvent.skipOnBoarding() = _skipOnBoarding;
}
