import 'package:felicitup_app/features/video_editor/views/mobile/video_editor_mobile_page.dart';
import 'package:flutter/material.dart';

class VideoEditorWebPage extends StatelessWidget {
  const VideoEditorWebPage({
    super.key,
    required this.felicitupId,
    required this.videoUrl,
  });

  final String felicitupId;
  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: VideoEditorMobilePage(
          felicitupId: felicitupId,
          videoUrl: videoUrl,
        ),
      ),
    );
  }
}
