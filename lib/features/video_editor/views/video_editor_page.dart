import 'package:felicitup_app/features/video_editor/views/mobile/video_editor_mobile_page.dart';
import 'package:felicitup_app/features/video_editor/views/web/video_editor_web_page.dart';
import 'package:flutter/material.dart';

class VideoEditorPage extends StatelessWidget {
  const VideoEditorPage({
    super.key,
    required this.felicitupId,
    required this.videoUrl,
  });

  final String felicitupId;
  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return VideoEditorWebPage(
            felicitupId: felicitupId,
            videoUrl: videoUrl,
          );
        }

        return VideoEditorMobilePage(
          felicitupId: felicitupId,
          videoUrl: videoUrl,
        );
      },
    );
  }
}
