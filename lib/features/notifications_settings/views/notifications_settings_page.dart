import 'package:felicitup_app/features/notifications_settings/views/mobile/notifications_settings_mobile_page.dart';
import 'package:felicitup_app/features/notifications_settings/views/web/notifications_settings_web_page.dart';
import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth > 1024) {
          return const NotificationsSettingsWebPage();
        }

        return const NotificationsSettingsMobilePage();
      },
    );
  }
}
