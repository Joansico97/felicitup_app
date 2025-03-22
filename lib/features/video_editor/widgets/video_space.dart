import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class VideoSpace extends StatelessWidget {
  const VideoSpace({
    super.key,
    required this.setVideo,
    required this.label,
    required this.id,
    required this.hasVideo,
    this.name,
    this.screenshotImage,
  });

  final String label;
  final String? name;
  final VoidCallback setVideo;
  final String id;
  final bool hasVideo;
  final String? screenshotImage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: setVideo,
      child: Padding(
        padding: EdgeInsets.all(context.sp(10)),
        child: Container(
          height: context.fullHeight,
          width: context.sp(100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.sp(10)),
            color: context.colors.grey,
          ),
          child: hasVideo
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(context.sp(10)),
                  child: SizedBox(
                    child: screenshotImage != null
                        ? Image.network(
                            screenshotImage!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: context.colors.grey,
                            child: Center(
                              child: Text(
                                name ?? '',
                                style: context.styles.subtitle,
                              ),
                            ),
                          ),
                  ),
                )
              : Center(
                  child: SizedBox(
                    width: context.sp(100),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: context.styles.subtitle,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
