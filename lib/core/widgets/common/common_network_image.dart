import 'package:cached_network_image/cached_network_image.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class CommonNetworkImage extends StatelessWidget {
  const CommonNetworkImage({
    super.key,
    required this.imageUrl,
    this.errorWidget,
  });

  final String imageUrl;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: context.sp(40),
      width: context.sp(40),
      fit: BoxFit.cover,
      placeholder: (_, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.sp(8)),
            color: Colors.white,
          ),
        ),
      ),
      errorWidget: (_, url, error) => errorWidget != null
          ? errorWidget!
          : Container(
              height: context.sp(194),
              width: context.sp(330),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.sp(8)),
                color: context.colors.orange,
              ),
              child: PhosphorIcon(
                PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                size: context.sp(25),
                color: context.colors.lightGrey,
              ),
            ),
    );
  }
}
