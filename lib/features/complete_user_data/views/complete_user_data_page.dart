import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/complete_user_data/bloc/complete_user_data_bloc.dart';
import 'package:felicitup_app/features/complete_user_data/views/mobile/complete_user_data_mobile_page.dart';
import 'package:felicitup_app/features/complete_user_data/views/web/complete_user_data_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CompleteUserDataPage extends StatelessWidget {
  const CompleteUserDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompleteUserDataBloc, CompleteUserDataState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.status != current.status,
      listener: (context, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == CompleteUserDataStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error'),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (state.status == CompleteUserDataStatus.success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.locale.save_success),
              duration: const Duration(seconds: 2),
            ),
          );
          context.go(RouterPaths.felicitupsDashboard);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return const CompleteUserDataWebPage();
          }

          return const CompleteUserDataMobilePage();
        },
      ),
    );
  }
}
