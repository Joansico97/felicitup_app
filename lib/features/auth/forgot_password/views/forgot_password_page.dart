import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:felicitup_app/features/auth/login/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listenWhen:
          (previous, current) =>
              previous.isLoading != current.isLoading ||
              previous.status != current.status,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == Status.success) {
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Se ha enviado un correo electrónico para reestablecer tu contraseña',
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          context.go(RouterPaths.login);
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SizedBox(
            height: context.fullHeight,
            width: context.fullWidth,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: -context.sp(70),
                    left: -context.sp(70),
                    child: Container(
                      height: context.sp(200),
                      width: context.sp(200),
                      decoration: BoxDecoration(
                        color: context.colors.primary.valueOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -context.sp(70),
                    right: -context.sp(70),
                    child: Container(
                      height: context.sp(200),
                      width: context.sp(200),
                      decoration: BoxDecoration(
                        color: context.colors.primary.valueOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        CollapsedHeader(
                          title: 'Olvidaste tu contraseña?',
                          onPressed: () => context.go(RouterPaths.login),
                        ),
                        const ForgotPasswordForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(24),
        vertical: context.sp(20),
      ),
      child: Column(
        children: [
          Text(
            'Ingresa tu correo electrónico para reestablecer tu contraseña',
            textAlign: TextAlign.center,
            style: context.styles.header2,
          ),
          SizedBox(height: context.sp(20)),
          Text(
            'Te enviaremos un correo electrónico con un enlace para reestablecer tu contraseña',
            textAlign: TextAlign.center,
            style: context.styles.paragraph,
          ),
          SizedBox(height: context.sp(20)),
          LoginInput(controller: emailController, hintText: 'Email'),
          SizedBox(height: context.sp(24)),
          SizedBox(
            height: context.sp(45),
            width: context.sp(172),
            child: PrimaryButton(
              onTap: () {
                context.read<ForgotPasswordBloc>().add(
                  ForgotPasswordEvent.sendEmailEvent(emailController.text),
                );
              },
              label: 'Enviar',
              isActive: true,
            ),
          ),
        ],
      ),
    );
  }
}
