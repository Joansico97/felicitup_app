import 'package:felicitup_app/features/details_felicitup/video_felicitup/views/mobile/video_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/details_felicitup/video_felicitup/views/web/video_felicitup_web_page.dart';
import 'package:flutter/material.dart';

class VideoFelicitupPage extends StatelessWidget {
  const VideoFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const VideoFelicitupWebPage();
        }

        return const VideoFelicitupMobilePage();
      },
    );
  }
}
