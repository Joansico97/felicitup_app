import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/auth/register/bloc/register_bloc.dart';
import 'package:felicitup_app/features/auth/register/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterMobileView extends StatelessWidget {
  const RegisterMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Container(
            height: context.fullHeight,
            width: context.fullWidth,
            padding: EdgeInsets.symmetric(vertical: context.sp(12)),
            child: BlocBuilder<RegisterBloc, RegisterState>(
              builder: (_, state) {
                final currentStep = state.currentStep;
                if (currentStep == 0) {
                  return const RegisterView();
                } else if (currentStep == 1) {
                  return const GetUserPhoneView();
                } else if (currentStep == 2) {
                  return const ValidateCodeView();
                } else if (currentStep == 3) {
                  return const FinishRegisterView();
                } else {
                  return const RegisterView();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
