import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/notifications_settings/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  List<bool> switchList = [true, true];
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
              label: 'Notificaciones',
              stateValue: switchList[0],
              onChanged: (v) => setState(() {
                switchList[0] = v;
              }),
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
