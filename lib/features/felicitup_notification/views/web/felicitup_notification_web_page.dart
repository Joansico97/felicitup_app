import 'package:felicitup_app/features/felicitup_notification/views/mobile/felicitup_notification_mobile_page.dart';
import 'package:flutter/material.dart';

class FelicitupNotificationWebPage extends StatelessWidget {
  const FelicitupNotificationWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const FelicitupNotificationMobilePage(),
      ),
    );
  }
}
