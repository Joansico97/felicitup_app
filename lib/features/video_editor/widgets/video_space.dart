import 'package:cached_network_image/cached_network_image.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
            color: context.colors.darkGrey.valueOpacity(.5),
          ),
          child: hasVideo
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(context.sp(10)),
                  child: SizedBox(
                    child: screenshotImage != null
                        ? CachedNetworkImage(
                            imageUrl: screenshotImage ?? '',
                            height: context.fullHeight,
                            width: context.sp(100),
                            fit: BoxFit.cover,
                            placeholder: (_, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    context.sp(8),
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (_, url, error) => Text(
                              name?.split(' ')[0] ?? '',
                              style: context.styles.subtitle,
                            ),
                          )
                        : Container(
                            color: context.colors.grey,
                            child: Center(
                              child: Text(
                                name?.split(' ')[0] ?? '',
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
