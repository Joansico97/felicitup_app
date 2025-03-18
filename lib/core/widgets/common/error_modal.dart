import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:flutter/material.dart';

Future<void> showErrorModal(String error) async {
  return await showDialog<void>(
    context: rootNavigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: context.sp(12),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Padding(
              padding: EdgeInsets.only(
                top: context.sp(8),
                left: context.sp(8),
                right: context.sp(8),
                bottom: context.sp(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        color: context.colors.error,
                        size: context.sp(12),
                      ),
                      SizedBox(width: context.sp(4)),
                      Text(
                        'Error',
                        style: context.styles.header2,
                      ),
                    ],
                  ),
                  SizedBox(height: context.sp(8)),
                  Text(
                    error,
                    style: context.styles.paragraph,
                  ),
                  SizedBox(height: context.sp(8)),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(rootNavigatorKey.currentContext!).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: context.colors.primary,
                        disabledBackgroundColor: context.colors.primary.valueOpacity(.2),
                        overlayColor: context.colors.lightGrey,
                      ),
                      child: Text(
                        'Aceptar',
                        style: context.styles.paragraph.copyWith(
                          color: context.colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
