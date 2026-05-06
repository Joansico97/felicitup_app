import 'dart:async';

import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/federated_register/bloc/federated_register_bloc.dart';
import 'package:felicitup_app/features/auth/federated_register/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FederatedRegisterPage extends StatelessWidget {
  const FederatedRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FederatedRegisterBloc, FederatedRegisterState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.status != current.status,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == FederatedRegisterStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error desconocido'),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (state.status == FederatedRegisterStatus.success &&
            context.mounted) {
          context.go(RouterPaths.onBoarding);
        }
      },
      child: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth > 1024) {
            return const FederatedRegisterWebView();
          }

          return const FederatedRegisterMobileView();
        },
      ),
    );
  }
}
