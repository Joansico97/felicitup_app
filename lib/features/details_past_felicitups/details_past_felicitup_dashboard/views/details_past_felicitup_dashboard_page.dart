import 'dart:async';

import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitup_dashboard/bloc/details_past_felicitup_dashboard_bloc.dart';
import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitup_dashboard/views/mobile/details_past_felicitup_dashboard_mobile_page.dart';
import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitup_dashboard/views/web/details_past_felicitup_dashboard_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailsPastFelicitupDashboardPage extends StatelessWidget {
  const DetailsPastFelicitupDashboardPage({
    super.key,
    required this.childView,
  });

  final Widget childView;

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      DetailsPastFelicitupDashboardBloc,
      DetailsPastFelicitupDashboardState
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
            return DetailsPastFelicitupDashboardWebPage(childView: childView);
          }

          return DetailsPastFelicitupDashboardMobilePage(childView: childView);
        },
      ),
    );
  }
}
