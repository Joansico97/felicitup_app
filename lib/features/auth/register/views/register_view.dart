import 'dart:io';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/register/bloc/register_bloc.dart';
import 'package:felicitup_app/features/auth/register/widgets/register_form.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
      child: Column(
        children: [
          Image.asset(Assets.images.logo.path, height: context.sp(60)),
          SizedBox(height: context.sp(12)),
          Image.asset(Assets.images.logoLetter.path, height: context.sp(62)),
          SizedBox(height: context.sp(12)),
          RegisterForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: context.sp(1),
                width: context.sp(123),
                color: Colors.black,
              ),
              Text('O', style: context.styles.header2),
              Container(
                height: context.sp(1),
                width: context.sp(123),
                color: Colors.black,
              ),
            ],
          ),
          SizedBox(height: context.sp(12)),
          SizedBox(
            height: context.sp(40),
            width: context.sp(240),
            child: BlocBuilder<RegisterBloc, RegisterState>(
              builder: (_, state) {
                return AppSocialRegularButton(
                  onTap:
                      () => context.read<RegisterBloc>().add(
                        RegisterEvent.googleLoginEvent(),
                      ),
                  label: 'Registrate con Google',
                  isActive: true,
                  icon: Assets.icons.googleIcon,
                  isLoading: false,
                );
              },
            ),
          ),
          SizedBox(height: context.sp(12)),
          Visibility(
            visible: Platform.isIOS,
            child: SizedBox(
              height: context.sp(40),
              width: context.sp(240),
              child: BlocBuilder<RegisterBloc, RegisterState>(
                builder: (_, state) {
                  return AppSocialRegularButton(
                    onTap:
                        () => context.read<RegisterBloc>().add(
                          RegisterEvent.appleLoginEvent(),
                        ),
                    label: 'Registrate con Apple',
                    isActive: true,
                    icon: Assets.icons.appleIcon,
                    isLoading: false,
                  );
                },
              ),
            ),
          ),
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
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () => context.push(RouterPaths.login),
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
