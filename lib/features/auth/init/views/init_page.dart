import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/auth/init/bloc/init_bloc.dart';
import 'package:flutter/material.dart';
import 'package:felicitup_app/features/auth/init/views/init_mobile_view.dart';
import 'package:felicitup_app/features/auth/init/views/init_web_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InitBloc, InitState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (_, state) {
        if (state.status == InitEnum.cannotContinue) {
          context.go(RouterPaths.updatePage);
        }
      },
      child: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth > 1024) {
            return const InitWebView();
          }

          return const InitMobileView();
        },
      ),
    );
  }
}
