import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/auth/register/widgets/register_form.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
            Assets.images.logo.path,
            height: context.sp(60),
          ),
          SizedBox(height: context.sp(12)),
          Image.asset(
            Assets.images.logoLetter.path,
            height: context.sp(62),
          ),
          SizedBox(height: context.sp(12)),
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
    );
  }
}
