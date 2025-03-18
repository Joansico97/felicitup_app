import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/auth/register/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Container(
            height: context.fullHeight,
            width: context.fullWidth,
            padding: EdgeInsets.symmetric(
              horizontal: context.sp(60),
              vertical: context.sp(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: context.sp(42)),
                  Image.asset(
                    Assets.images.logo.path,
                    height: context.sp(60),
                  ),
                  SizedBox(height: context.sp(23)),
                  Image.asset(
                    Assets.images.logoLetter.path,
                    height: context.sp(62),
                  ),
                  SizedBox(height: context.sp(24)),
                  RegisterForm(),
                  SizedBox(height: context.sp(12)),
                  RichText(
                    text: TextSpan(
                      text: '¿Ya estás registrado?',
                      style: context.styles.smallText,
                      children: [
                        TextSpan(
                          text: ' Acceder',
                          style: context.styles.smallText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () => context.push(RouterPaths.login),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: size.height(.03)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
