import 'package:felicitup_app/features/details_past_felicitups/people_past_felicitup/views/mobile/people_past_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/details_past_felicitups/people_past_felicitup/views/web/people_past_felicitup_web_page.dart';
import 'package:flutter/material.dart';

class PeoplePastFelicitupPage extends StatelessWidget {
  const PeoplePastFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const PeoplePastFelicitupWebPage();
        }

        return const PeoplePastFelicitupMobilePage();
      },
    );
  }
}
