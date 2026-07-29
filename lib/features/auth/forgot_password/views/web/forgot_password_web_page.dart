import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:felicitup_app/features/auth/login/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordWebPage extends StatelessWidget {
  const ForgotPasswordWebPage({super.key});

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
            width: context.sp(450),
            child: Container(
              padding: EdgeInsets.all(context.sp(24)),
              decoration: BoxDecoration(
                color: context.colors.backgroundModal,
                borderRadius: BorderRadius.circular(context.sp(24)),
                border: Border.all(color: context.colors.lightGrey),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CollapsedHeader(
                    title: context.locale.forgot_password_title,
                    onPressed: () => context.go(RouterPaths.login),
                  ),
                  const ForgotPasswordWebForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordWebForm extends StatefulWidget {
  const ForgotPasswordWebForm({super.key});

  @override
  State<ForgotPasswordWebForm> createState() => _ForgotPasswordWebFormState();
}

class _ForgotPasswordWebFormState extends State<ForgotPasswordWebForm> {
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
    return Column(
      children: [
        SizedBox(height: context.sp(16)),
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
    );
  }
}
