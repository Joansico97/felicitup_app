import 'package:felicitup_app/features/details_past_felicitups/main_past_felicitup/views/mobile/main_past_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/details_past_felicitups/main_past_felicitup/views/web/main_past_felicitup_web_page.dart';
import 'package:flutter/material.dart';

class MainPastFelicitupPage extends StatelessWidget {
  const MainPastFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const MainPastFelicitupWebPage();
        }

        return const MainPastFelicitupMobilePage();
      },
    );
  }
}
