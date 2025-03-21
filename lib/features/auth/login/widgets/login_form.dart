import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/login/bloc/login_bloc.dart';
import 'package:felicitup_app/features/auth/login/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Form(
        child: Column(
          children: [
            LoginInput(
              controller: emailController,
              hintText: 'Email',
            ),
            SizedBox(height: context.sp(12)),
            LoginInput(
              controller: passwordController,
              hintText: 'Contraseña',
              isPassword: true,
              isObscure: isObscure,
              changeObscure: () => setState(() {
                isObscure = !isObscure;
              }),
            ),
            SizedBox(height: context.sp(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => context.push(RouterPaths.resetPassword),
                  child: Text(
                    'Olvidaste tu contraseña?',
                    style: context.styles.smallText,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.sp(24)),
            SizedBox(
              height: context.sp(45),
              width: context.sp(172),
              child: PrimaryButton(
                onTap: () => context.read<LoginBloc>().add(
                      LoginEvent.loginEvent(
                        emailController.text,
                        passwordController.text,
                      ),
                    ),
                isBig: false,
                label: 'Acceder',
                isActive: true,
              ),
            ),
            SizedBox(height: context.sp(24)),
            RichText(
              text: TextSpan(
                text: 'Aún no tienes cuenta? ',
                style: context.styles.paragraph,
                children: [
                  TextSpan(
                    text: 'Registrate',
                    style: context.styles.paragraph.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () => context.push(RouterPaths.register),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
