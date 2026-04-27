import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/on_boarding/bloc/on_boarding_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnBoardingMobileView extends StatelessWidget {
  const OnBoardingMobileView({super.key});

  String _getBackgroundImage(int index) {
    switch (index) {
      case 0:
        return Assets.images.onBoarding.onBoardingFelicitup01.path;
      case 1:
        return Assets.images.onBoarding.onBoardingFelicitup02.path;
      case 2:
        return Assets.images.onBoarding.onBoardingFelicitup03.path;
      case 3:
        return Assets.images.onBoarding.onBoardingFelicitup04.path;
      case 4:
        return Assets.images.onBoarding.onBoardingFelicitup05.path;
      case 5:
        return Assets.images.onBoarding.onBoardingFelicitup06.path;
      case 6:
        return Assets.images.onBoarding.onBoardingFelicitup07.path;
      case 7:
        return Assets.images.onBoarding.onBoardingFelicitup08.path;
      case 8:
        return Assets.images.onBoarding.onBoardingFelicitup09.path;
      case 9:
        return Assets.images.onBoarding.onBoardingFelicitup10.path;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: context.fullHeight,
            width: context.fullWidth,
            child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
              builder: (_, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (widget, animation) =>
                      FadeTransition(opacity: animation, child: widget),
                  child: Image.asset(
                    key: ValueKey(state.currentPage),
                    _getBackgroundImage(state.currentPage),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: context.screenPadding.bottom + context.sp(24),
            child: Row(
              children: [
                FadeIn(
                  child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
                    builder: (_, state) {
                      return SizedBox(
                        height: context.sp(50),
                        width: context.sp(150),
                        child: PrimaryButton(
                          label: state.currentPage != 9
                              ? 'Continuar'
                              : 'Empezar',
                          onTap: () {
                            context.read<OnBoardingBloc>().add(
                              const OnBoardingEvent.changeIndex(),
                            );
                          },
                          isActive: true,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: context.sp(25)),
                FadeIn(
                  child: SizedBox(
                    height: context.sp(50),
                    width: context.sp(150),
                    child: PrimaryButton(
                      label: 'Saltar',
                      onTap: () {
                        context.read<OnBoardingBloc>().add(
                          const OnBoardingEvent.skipOnBoarding(),
                        );
                      },
                      isActive: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
