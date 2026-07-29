import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:felicitup_app/features/auth/forgot_password/views/mobile/forgot_password_mobile_page.dart';
import 'package:felicitup_app/features/auth/forgot_password/views/web/forgot_password_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.status != current.status,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == Status.success) {
          if (rootNavigatorKey.currentContext != null) {
            ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text(
                  rootNavigatorKey.currentContext!.locale.forgot_password_success,
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }

          context.go(RouterPaths.login);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return const ForgotPasswordWebPage();
          }

          return const ForgotPasswordMobilePage();
        },
      ),
    );
  }
}
