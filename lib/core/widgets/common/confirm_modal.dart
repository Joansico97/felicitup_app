import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../core/router/router.dart';

Future<void> showConfirmModal({
  required String title,
  String? content,
  required Future<void> Function() onAccept,
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
          padding: EdgeInsets.only(
            top: context.sp(24),
            left: context.sp(24),
            right: context.sp(24),
            bottom: context.sp(12),
          ),
          decoration: BoxDecoration(
            color: context.colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(context.sp(1)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.orange,
                      ),
                      child: Icon(
                        Icons.close,
                        color: context.colors.white,
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
                SizedBox(
                  height: context.sp(24),
                ),
                if (content != null)
                  Column(
                    children: [
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: context.styles.paragraph,
                      ),
                      SizedBox(
                        height: context.sp(24),
                      ),
                    ],
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(rootNavigatorKey.currentContext!).pop();
                        await onAccept();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.orange,
                        disabledBackgroundColor: context.colors.lightGrey,
                        elevation: 0,
                      ),
                      child: Text(
                        'Aceptar',
                        style: context.styles.buttons.copyWith(
                          color: context.colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(rootNavigatorKey.currentContext!).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.otherGrey,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: context.colors.lightGrey,
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancelar',
                        style: context.styles.buttons.copyWith(
                          color: context.colors.white,
                        ),
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
