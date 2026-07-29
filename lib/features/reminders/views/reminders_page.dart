import 'package:felicitup_app/features/reminders/views/mobile/reminders_mobile_page.dart';
import 'package:felicitup_app/features/reminders/views/web/reminders_web_page.dart';
import 'package:flutter/material.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const RemindersWebPage();
        }

        return const RemindersMobilePage();
      },
    );
  }
}
