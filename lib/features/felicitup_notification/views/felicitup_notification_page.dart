import 'package:felicitup_app/features/felicitup_notification/views/mobile/felicitup_notification_mobile_page.dart';
import 'package:felicitup_app/features/felicitup_notification/views/web/felicitup_notification_web_page.dart';
import 'package:flutter/material.dart';

class FelicitupNotificationPage extends StatelessWidget {
  const FelicitupNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const FelicitupNotificationWebPage();
        }

        return const FelicitupNotificationMobilePage();
      },
    );
  }
}
