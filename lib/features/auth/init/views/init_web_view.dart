import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InitWebView extends StatelessWidget {
  const InitWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 520,
                  width: 400,
                  decoration: BoxDecoration(
                    color: context.colors.lightGrey,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      Image.asset(
                        Assets.images.logo.path,
                        fit: BoxFit.contain,
                        height: 77,
                      ),
                      const SizedBox(height: 32),
                      Image.asset(
                        Assets.images.logoLetter.path,
                        fit: BoxFit.contain,
                        width: 276,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'La app para amigos de verdad',
                        style: context.styles.paragraph,
                      ),
                      const SizedBox(height: 39),
                      SizedBox(
                        width: 172,
                        height: 50,
                        child: PrimaryButton(
                          onTap: () => context.push(RouterPaths.register),
                          label: 'Crear cuenta',
                          isActive: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                RichText(
                  text: TextSpan(
                    text: '¿Ya tienes una cuenta? ',
                    style: context.styles.paragraph,
                    children: [
                      TextSpan(
                        text: 'Inicia sesión',
                        style: context.styles.paragraph.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push(RouterPaths.login),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
