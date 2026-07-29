import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/features/on_boarding/bloc/on_boarding_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnBoardingBloc', () {
    test('initial state is correct', () {
      final bloc = OnBoardingBloc();
      expect(bloc.state, OnBoardingState.initial());
    });

    blocTest<OnBoardingBloc, OnBoardingState>(
      'increments currentPage when changeIndex is added',
      build: () => OnBoardingBloc(),
      act: (bloc) => bloc.add(const OnBoardingEvent.changeIndex()),
      expect: () => [
        OnBoardingState.initial().copyWith(currentPage: 1),
      ],
    );

    blocTest<OnBoardingBloc, OnBoardingState>(
      'emits finish state on skipOnBoarding',
      build: () => OnBoardingBloc(),
      act: (bloc) => bloc.add(const OnBoardingEvent.skipOnBoarding()),
      expect: () => [
        OnBoardingState.initial().copyWith(
          finishEnum: OnBoardingFinishEnum.finish,
        ),
      ],
    );
  });
}
