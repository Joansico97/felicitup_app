import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InitWebPage extends StatelessWidget {
  const InitWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(20),
            vertical: context.sp(40),
          ),
          child: SizedBox(
            width: context.sp(400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: context.sp(520),
                  width: context.sp(400),
                  decoration: BoxDecoration(
                    color: context.colors.lightGrey,
                    borderRadius: BorderRadius.circular(context.sp(40)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: context.sp(80)),
                      Image.asset(
                        Assets.images.logo.path,
                        fit: BoxFit.contain,
                        height: context.sp(77),
                      ),
                      SizedBox(height: context.sp(32)),
                      Image.asset(
                        Assets.images.logoLetter.path,
                        fit: BoxFit.contain,
                        width: context.sp(276),
                      ),
                      SizedBox(height: context.sp(12)),
                      Text(
                        context.locale.app_tagline,
                        style: context.styles.paragraph,
                      ),
                      SizedBox(height: context.sp(39)),
                      SizedBox(
                        width: context.sp(172),
                        height: context.sp(50),
                        child: PrimaryButton(
                          onTap: () => context.push(RouterPaths.register),
                          label: context.locale.create_account,
                          isActive: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.sp(40)),
                RichText(
                  text: TextSpan(
                    text: context.locale.already_have_account,
                    style: context.styles.paragraph,
                    children: [
                      TextSpan(
                        text: context.locale.login_action,
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
