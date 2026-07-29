import 'dart:async';

import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/create_felicitup/views/mobile/create_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/create_felicitup/views/web/create_felicitup_web_page.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateFelicitupPage extends StatelessWidget {
  const CreateFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateFelicitupBloc, CreateFelicitupState>(
          listenWhen: (previous, current) =>
              previous.isLoading != current.isLoading ||
              previous.status != current.status,
          listener: (_, state) async {
            if (state.isLoading) {
              unawaited(startLoadingModal());
            } else {
              await stopLoadingModal();
            }

            if (state.status == CreateStatus.success) {
              showFinishModal(() {
                context.read<CreateFelicitupBloc>().add(
                      const CreateFelicitupEvent.deleteCurrentFelicitup(),
                    );
                context.go(RouterPaths.felicitupsDashboard);
              });
            }
          },
        ),
        BlocListener<CreateFelicitupBloc, CreateFelicitupState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage,
          listener: (_, state) async {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              showErrorModal(state.errorMessage!);
            }
          },
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return const CreateFelicitupWebPage();
          }

          return const CreateFelicitupMobilePage();
        },
      ),
    );
  }
}
