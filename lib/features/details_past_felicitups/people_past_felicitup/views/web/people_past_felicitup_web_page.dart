import 'package:felicitup_app/features/details_past_felicitups/people_past_felicitup/views/mobile/people_past_felicitup_mobile_page.dart';
import 'package:flutter/material.dart';

class PeoplePastFelicitupWebPage extends StatelessWidget {
  const PeoplePastFelicitupWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const PeoplePastFelicitupMobilePage(),
      ),
    );
  }
}
