import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/register/bloc/register_bloc.dart';
import 'package:felicitup_app/features/auth/register/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen:
          (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == RegisterStatus.finished) {
          if (context.mounted) {
            context.go(RouterPaths.login);
          }
        }

        if (state.status == RegisterStatus.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }

        if (state.status == RegisterStatus.federated) {
          if (context.mounted) {
            context.read<AppBloc>().add(
              AppEvent.loadProvUserData(state.federatedUser!),
            );
            context.go(RouterPaths.federatedRegister);
          }
        }

        if (state.status == RegisterStatus.federatedFinished) {
          if (context.mounted) {
            context.read<AppBloc>().add(AppEvent.loadUserData());
            context.go(RouterPaths.onBoarding);
          }
        }
      },
      child: Scaffold(
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
                    return RegisterView();
                  } else if (currentStep == 1) {
                    return GetUserPhoneView();
                  } else if (currentStep == 2) {
                    return ValidateCodeView();
                  } else if (currentStep == 3) {
                    return FinishRegisterView();
                  } else {
                    return RegisterView();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
