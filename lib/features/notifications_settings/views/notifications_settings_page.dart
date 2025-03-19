import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

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
          ],
        ),
      ),
    );
  }
}
