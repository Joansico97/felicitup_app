import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/login/bloc/login_bloc.dart';
import 'package:felicitup_app/features/auth/login/views/login_mobile_view.dart';
import 'package:felicitup_app/features/auth/login/views/login_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == LoginStatus.error) {
          unawaited(showErrorModal(state.errorMessage));

          context.read<LoginBloc>().add(LoginEvent.changeEvent());
        }

        if (state.status == LoginStatus.federated) {
          context.go(RouterPaths.federatedRegister);
        }

        if (state.status == LoginStatus.success) {
          context.read<AppBloc>().add(AppEvent.loadUserData());
          if (state.isFirstTime) {
            context.read<LoginBloc>().add(LoginEvent.changeFirstTimeRedirect());
            context.go(RouterPaths.onBoarding);
          } else {
            context.go(RouterPaths.felicitupsDashboard);
          }
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (_, constraints) {
            if (constraints.maxWidth > 1024) {
              return const LoginWebView();
            }

            return const LoginMobileView();
          },
        ),
      ),
    );
  }
}
