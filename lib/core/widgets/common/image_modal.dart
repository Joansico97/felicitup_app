import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showImageModal(
  BuildContext context,
  String imageUrl,
) {
  showDialog(
    context: context,
    barrierColor: context.colors.black.valueOpacity(.5),
    builder: (context) {
      return Dialog(
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            height: context.sp(400),
            width: context.sp(400),
            padding: EdgeInsets.all(context.sp(10)),
            decoration: BoxDecoration(
              color: context.colors.white,
              borderRadius: BorderRadius.circular(context.sp(20)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.sp(20)),
              child: Image.network(
                imageUrl,
                // fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    },
  );
}
