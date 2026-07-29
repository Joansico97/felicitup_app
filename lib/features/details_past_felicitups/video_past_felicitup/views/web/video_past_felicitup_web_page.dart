import 'package:felicitup_app/features/details_past_felicitups/video_past_felicitup/views/mobile/video_past_felicitup_mobile_page.dart';
import 'package:flutter/material.dart';

class VideoPastFelicitupWebPage extends StatelessWidget {
  const VideoPastFelicitupWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const VideoPastFelicitupMobilePage(),
      ),
    );
  }
}
