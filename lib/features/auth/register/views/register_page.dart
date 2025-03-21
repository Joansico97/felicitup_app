import 'dart:async';

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
      listenWhen: (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == RegisterStatus.finished) {
          context.go(RouterPaths.login);
        }

        if (state.status == RegisterStatus.error) {
          unawaited(showErrorModal(state.errorMessage));
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Container(
              height: context.fullHeight,
              width: context.fullWidth,
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(60),
                vertical: context.sp(12),
              ),
              child: BlocBuilder<RegisterBloc, RegisterState>(
                builder: (_, state) {
                  final status = state.status;
                  if (status == RegisterStatus.success) {
                    return FinishRegisterView();
                  } else if (status == RegisterStatus.initial) {
                    return RegisterView();
                  } else if (status == RegisterStatus.formFinished) {
                    return GetUserPhoneView();
                  } else if (status == RegisterStatus.validateCode) {
                    return ValidateCodeView();
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
