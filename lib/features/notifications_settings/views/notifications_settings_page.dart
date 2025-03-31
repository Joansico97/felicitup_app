import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/notifications_settings/widgets/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  List<bool> switchList = [
    rootNavigatorKey.currentContext!.read<AppBloc>().state.status == AuthorizationStatus.authorized,
    true,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CollapsedHeader(
              title: 'Configuración de notificaciones',
              onPressed: () async => context.go(RouterPaths.felicitupsDashboard),
            ),
            SizedBox(height: context.sp(12)),
            SizedBox(
              width: context.sp(300),
              child: Text(
                'Notificaciones',
                style: context.styles.header2,
              ),
            ),
            SizedBox(height: context.sp(12)),
            SwitchButton(
              label: 'Recibir notificaciones',
              stateValue: switchList[0],
              onChanged: (v) {
                if (v) {
                  context.read<AppBloc>().add(const AppEvent.requestManualPermissions());
                } else {
                  context.read<AppBloc>().add(const AppEvent.deleterPermissions());
                }
                setState(() {
                  switchList[0] = v;
                });
              },
            ),
            SwitchButton(
              label: 'Vibración',
              stateValue: switchList[1],
              onChanged: (v) => setState(() {
                switchList[1] = v;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
