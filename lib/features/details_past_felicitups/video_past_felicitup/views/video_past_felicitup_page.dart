import 'package:felicitup_app/features/details_past_felicitups/video_past_felicitup/views/mobile/video_past_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/details_past_felicitups/video_past_felicitup/views/web/video_past_felicitup_web_page.dart';
import 'package:flutter/material.dart';

class VideoPastFelicitupPage extends StatelessWidget {
  const VideoPastFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const VideoPastFelicitupWebPage();
        }

        return const VideoPastFelicitupMobilePage();
      },
    );
  }
}
