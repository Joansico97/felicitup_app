import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/notifications_settings/widgets/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotificationsSettingsMobilePage extends StatefulWidget {
  const NotificationsSettingsMobilePage({super.key});

  @override
  State<NotificationsSettingsMobilePage> createState() =>
      _NotificationsSettingsMobilePageState();
}

class _NotificationsSettingsMobilePageState
    extends State<NotificationsSettingsMobilePage> {
  late List<bool> switchList;

  @override
  void initState() {
    super.initState();
    final appBloc = rootNavigatorKey.currentContext?.read<AppBloc>();
    switchList = [
      appBloc?.state.status == AuthorizationStatus.authorized,
      true,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            CollapsedHeader(
              title: 'Configuración de notificaciones',
              onPressed: () async =>
                  context.go(RouterPaths.felicitupsDashboard),
            ),
            SizedBox(height: context.sp(12)),
            SizedBox(
              width: context.sp(300),
              child: Text('Notificaciones', style: context.styles.header2),
            ),
            SizedBox(height: context.sp(12)),
            SwitchButton(
              label: 'Recibir notificaciones',
              stateValue: switchList[0],
              onChanged: (v) {
                if (v) {
                  context.read<AppBloc>().add(
                        const AppEvent.requestManualPermissions(),
                      );
                } else {
                  context.read<AppBloc>().add(
                        const AppEvent.deleterPermissions(),
                      );
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
