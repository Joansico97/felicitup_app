import 'dart:async';

import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/felicitups_dashboard/bloc/felicitups_dashboard_bloc.dart';
import 'package:felicitup_app/features/felicitups_dashboard/views/dashboard_mobile_view.dart';
import 'package:felicitup_app/features/felicitups_dashboard/views/dashboard_web_view.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FelicitupsDashboardPage extends StatefulWidget {
  const FelicitupsDashboardPage({super.key, this.isFromPast});

  final bool? isFromPast;

  @override
  State<FelicitupsDashboardPage> createState() =>
      _FelicitupsDashboardPageState();
}

class _FelicitupsDashboardPageState extends State<FelicitupsDashboardPage> {
  late final PageController _felicitupsDashboardPageController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _felicitupsDashboardPageController = PageController();
    _pages = [InProgressSection(), PastSection()];
    context.read<FelicitupsDashboardBloc>().add(
      const FelicitupsDashboardEvent.startListening(),
    );
    context.read<FelicitupsDashboardBloc>().add(
      const FelicitupsDashboardEvent.getRememberStatus(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((widget.isFromPast ?? false) &&
          _felicitupsDashboardPageController.hasClients) {
        _felicitupsDashboardPageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        context.read<FelicitupsDashboardBloc>().add(
          FelicitupsDashboardEvent.changeIndex(1),
        );
      }
    });
  }

  @override
  void dispose() {
    _felicitupsDashboardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FelicitupsDashboardBloc, FelicitupsDashboardState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        // Manejar modal de carga reactivamente
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          unawaited(stopLoadingModal());
        }

        // Manejar errores
        if (state.status == FelicitupsDashboardStatus.error &&
            state.errorMessage != null) {
          unawaited(showErrorModal(state.errorMessage!));
        } else if (state.status == FelicitupsDashboardStatus.likeError) {
          unawaited(showErrorModal(state.errorMessage ?? 'Error al dar like'));
        }

        // Manejar navegación
        if (state.status == FelicitupsDashboardStatus.chatCreated &&
            state.createdChat != null) {
          context.go(
            RouterPaths.singleChat,
            extra: state.createdChat,
          );
        }
      },
      child: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth > 1024) {
            return DashboardWebView(
              felicitupsDashboardPageController:
                  _felicitupsDashboardPageController,
              pages: _pages,
            );
          }

          return DashboardMobileView(
            felicitupsDashboardPageController: _felicitupsDashboardPageController,
            pages: _pages,
          );
        },
      ),
    );
  }
}
