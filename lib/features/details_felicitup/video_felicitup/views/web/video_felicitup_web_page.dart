import 'package:felicitup_app/features/details_felicitup/video_felicitup/views/mobile/video_felicitup_mobile_page.dart';
import 'package:flutter/material.dart';

class VideoFelicitupWebPage extends StatelessWidget {
  const VideoFelicitupWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const VideoFelicitupMobilePage(),
      ),
    );
  }
}
