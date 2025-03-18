import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../core/router/router.dart';

Future<void> customModal({
  required String title,
  required Widget child,
  bool isColapsed = false,
}) async {
  return await showDialog<void>(
    context: rootNavigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: context.sp(24),
          ),
          constraints: BoxConstraints(
            maxHeight: isColapsed ? context.sp(200) : context.sp(300),
            minHeight: context.sp(50),
          ),
          padding: EdgeInsets.only(
            top: context.sp(24),
            left: context.sp(24),
            right: context.sp(24),
            bottom: context.sp(12),
          ),
          decoration: BoxDecoration(
            color: context.colors.lightGrey,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(context.sp(2)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.orange,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.sp(10)),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.styles.header2,
                ),
                SizedBox(height: context.sp(24)),
                child,
              ],
            ),
          ),
        ),
      );
    },
  );
}
