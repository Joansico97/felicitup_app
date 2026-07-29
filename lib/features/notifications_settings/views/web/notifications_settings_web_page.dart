import 'package:felicitup_app/features/notifications_settings/views/mobile/notifications_settings_mobile_page.dart';
import 'package:flutter/material.dart';

class NotificationsSettingsWebPage extends StatelessWidget {
  const NotificationsSettingsWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 600,
        child: NotificationsSettingsMobilePage(),
      ),
    );
  }
}
