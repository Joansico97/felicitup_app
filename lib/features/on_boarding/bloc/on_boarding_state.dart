part of 'on_boarding_bloc.dart';

enum OnBoardingFinishEnum { none, finish }

@freezed
class OnBoardingState with _$OnBoardingState {
  const factory OnBoardingState({
    required int currentPage,
    required OnBoardingFinishEnum finishEnum,
  }) = _OnBoardingState;
  factory OnBoardingState.initial() => const OnBoardingState(
    currentPage: 0,
    finishEnum: OnBoardingFinishEnum.none,
  );
}
