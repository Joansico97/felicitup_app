import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';

void showFinishModal(void Function()? onPressed) {
  showDialog(
    context: rootNavigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('¡Enhorabuena!'),
        titleTextStyle: context.styles.header1,
        content: const Text(
          'Tu Felicitup se ha creado correctamente. Hemos enviado una invitación a los miembros del grupo.',
          textAlign: TextAlign.center,
        ),
        contentTextStyle: context.styles.smallText,
        icon: Column(
          children: [
            Image.asset(
              Assets.images.logo.path,
              height: context.sp(30),
            ),
            SizedBox(height: context.sp(12)),
            Image.asset(
              Assets.images.logoLetter.path,
              height: context.sp(32),
            ),
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
