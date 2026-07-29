import 'dart:async';

import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/bloc/details_felicitup_dashboard_bloc.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/views/mobile/details_felicitup_dashboard_mobile_page.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/views/web/details_felicitup_dashboard_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailsFelicitupDashboardPage extends StatelessWidget {
  const DetailsFelicitupDashboardPage({
    super.key,
    required this.childView,
    required this.fromNotification,
    this.chatId,
  });

  final Widget childView;
  final bool fromNotification;
  final String? chatId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      DetailsFelicitupDashboardBloc,
      DetailsFelicitupDashboardState
    >(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (context, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return DetailsFelicitupDashboardWebPage(
              childView: childView,
              fromNotification: fromNotification,
              chatId: chatId,
            );
          }

          return DetailsFelicitupDashboardMobilePage(
            childView: childView,
            fromNotification: fromNotification,
            chatId: chatId,
          );
        },
      ),
    );
  }
}
