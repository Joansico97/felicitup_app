import 'package:felicitup_app/features/details_past_felicitups/main_past_felicitup/views/mobile/main_past_felicitup_mobile_page.dart';
import 'package:flutter/material.dart';

class MainPastFelicitupWebPage extends StatelessWidget {
  const MainPastFelicitupWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const MainPastFelicitupMobilePage(),
      ),
    );
  }
}
