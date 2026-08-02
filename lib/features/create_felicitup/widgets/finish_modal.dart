import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showFinishModal(void Function()? onPressed, {String? felicitupId}) {
  final String shareLink = 'https://app.felicitup.com/invite/$felicitupId'; // TODO: Update to actual domain later

  showDialog(
    context: rootNavigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('¡Enhorabuena!'),
        titleTextStyle: context.styles.header1,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tu Felicitup se ha creado correctamente.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.sp(10)),
            if (felicitupId != null) ...[
              Text(
                'Comparte este enlace para que otros se unan:',
                textAlign: TextAlign.center,
                style: context.styles.smallText.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: context.sp(8)),
              Container(
                padding: EdgeInsets.all(context.sp(8)),
                decoration: BoxDecoration(
                  color: context.colors.lightGrey,
                  borderRadius: BorderRadius.circular(context.sp(8)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        shareLink,
                        style: context.styles.smallText.copyWith(color: Colors.blue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enlace copiado al portapapeles')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        contentTextStyle: context.styles.smallText,
        icon: Column(
          children: [
            Image.asset(Assets.images.logo.path, height: context.sp(30)),
            SizedBox(height: context.sp(12)),
            Image.asset(Assets.images.logoLetter.path, height: context.sp(32)),
          ],
        ),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.orange,
                disabledBackgroundColor: context.colors.lightGrey,
                elevation: 0,
              ),
              child: Text(
                'Aceptar',
                style: context.styles.paragraph.copyWith(
                  color: context.colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
