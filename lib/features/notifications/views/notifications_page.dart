import 'dart:async';

import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:felicitup_app/features/notifications/views/mobile/notifications_mobile_page.dart';
import 'package:felicitup_app/features/notifications/views/web/notifications_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return const NotificationsWebPage();
          }

          return const NotificationsMobilePage();
        },
      ),
    );
  }
}
