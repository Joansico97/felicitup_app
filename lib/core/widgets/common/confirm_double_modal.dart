import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../core/router/router.dart';

Future<void> showConfirDoublemModal({
  required String title,
  required String label1,
  required String label2,
  String? label3,
  bool? isDestructive,
  bool? needOtherButton = false,
  required Future<void> Function() onAction1,
  required Future<void> Function() onAction2,
  Future<void> Function()? onAction3,
}) async {
  return await showDialog<void>(
    context: rootNavigatorKey.currentContext!,
    barrierDismissible: isDestructive ?? false,
    builder: (context) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.sp(24)),
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
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(context.sp(2)),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.orange),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: context.sp(10)),
                Text(title, textAlign: TextAlign.center, style: context.styles.header2),
                SizedBox(height: context.sp(24)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(rootNavigatorKey.currentContext!).pop();
                        await onAction1();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.orange,
                        disabledBackgroundColor: context.colors.lightGrey,
                        elevation: 0,
                      ),
                      child: Text(label1, style: context.styles.buttons.copyWith(color: context.colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(rootNavigatorKey.currentContext!).pop();
                        onAction2();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (needOtherButton ?? false) ? context.colors.orange : Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: context.colors.lightGrey,
                        elevation: 0,
                      ),
                      child: Text(
                        label2,
                        style: context.styles.buttons.copyWith(
                          color: (needOtherButton ?? false) ? context.colors.white : context.colors.black,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: needOtherButton ?? false,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(rootNavigatorKey.currentContext!).pop();
                          onAction3!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.orange,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: context.colors.lightGrey,
                          elevation: 0,
                        ),
                        child: Text(label3 ?? '', style: context.styles.buttons.copyWith(color: context.colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
