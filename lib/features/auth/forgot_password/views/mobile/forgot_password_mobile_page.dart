import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:felicitup_app/features/auth/login/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordMobilePage extends StatelessWidget {
  const ForgotPasswordMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        title: context.locale.forgot_password_title,
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
    );
  }
}

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(24),
        vertical: context.sp(20),
      ),
      child: Column(
        children: [
          Text(
            context.locale.forgot_password_subtitle,
            textAlign: TextAlign.center,
            style: context.styles.header2,
          ),
          SizedBox(height: context.sp(20)),
          Text(
            context.locale.forgot_password_info,
            textAlign: TextAlign.center,
            style: context.styles.paragraph,
          ),
          SizedBox(height: context.sp(20)),
          LoginInput(controller: _emailController, hintText: 'Email'),
          SizedBox(height: context.sp(24)),
          SizedBox(
            height: context.sp(45),
            width: context.sp(172),
            child: PrimaryButton(
              onTap: () {
                context.read<ForgotPasswordBloc>().add(
                      ForgotPasswordEvent.sendEmailEvent(
                          _emailController.text),
                    );
              },
              label: context.locale.send,
              isActive: true,
            ),
          ),
        ],
      ),
    );
  }
}
