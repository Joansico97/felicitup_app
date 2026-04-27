import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/on_boarding/bloc/on_boarding_bloc.dart';
import 'package:felicitup_app/features/on_boarding/views/on_boarding_mobile_view.dart';
import 'package:felicitup_app/features/on_boarding/views/on_boarding_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnBoardingBloc, OnBoardingState>(
      listenWhen: (previous, current) =>
          previous.finishEnum != current.finishEnum,
      listener: (_, state) {
        if (state.finishEnum == OnBoardingFinishEnum.finish) {
          context.go(RouterPaths.felicitupsDashboard);
        }
      },
      child: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth > 1024) {
            return const OnBoardingWebView();
          }

          return const OnBoardingMobileView();
        },
      ),
    );
  }
}
