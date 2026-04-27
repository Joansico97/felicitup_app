import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showErrorModal(String error) async {
  return await showDialog<void>(
    context: rootNavigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 12 : context.sp(12),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Padding(
              padding: EdgeInsets.only(
                top: kIsWeb ? 8 : context.sp(8),
                left: kIsWeb ? 8 : context.sp(8),
                right: kIsWeb ? 8 : context.sp(8),
                bottom: kIsWeb ? 4 : context.sp(4),
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
                        size: kIsWeb ? 12 : context.sp(12),
                      ),
                      SizedBox(width: kIsWeb ? 4 : context.sp(4)),
                      Text('Error', style: context.styles.header2),
                    ],
                  ),
                  SizedBox(height: kIsWeb ? 8 : context.sp(8)),
                  Text(error, style: context.styles.paragraph),
                  SizedBox(height: kIsWeb ? 8 : context.sp(8)),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: context.colors.primary,
                        disabledBackgroundColor: context.colors.primary
                            .valueOpacity(.2),
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
