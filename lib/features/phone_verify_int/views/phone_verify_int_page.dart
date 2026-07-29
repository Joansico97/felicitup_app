import 'dart:async';

import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/phone_verify_int/phone_verify_int.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PhoneVerifyIntPage extends StatelessWidget {
  const PhoneVerifyIntPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhoneVerifyIntBloc, PhoneVerifyIntState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.status != current.status,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == PhoneVerifyStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error desconocido'),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (state.status == PhoneVerifyStatus.success) {
          context.go(RouterPaths.felicitupsDashboard);
        }
      },
      child: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth > 1024) {
            return const PhoneVerifyIntWebPage();
          }

          return const PhoneVerifyIntMobilePage();
        },
      ),
    );
  }
}
