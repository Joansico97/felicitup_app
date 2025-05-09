import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/phone_verify_int/phone_verify_int.dart';
import 'package:felicitup_app/features/phone_verify_int/views/get_phone_view.dart';
import 'package:felicitup_app/features/phone_verify_int/views/validate_sms_code_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';

class PhoneVerifyIntPage extends StatelessWidget {
  const PhoneVerifyIntPage({super.key});

  @override
  Widget build(BuildContext context) {
    getView(int index) {
      switch (index) {
        case 0:
          return GetPhoneView();
        case 1:
          return ValidateSmsCodeView();
      }
    }

    return BlocListener<PhoneVerifyIntBloc, PhoneVerifyIntState>(
      listenWhen:
          (previous, current) =>
              previous.isLoading != current.isLoading ||
              previous.finished != current.finished,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.finished) {
          context.go(RouterPaths.felicitupsDashboard);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
            child: BlocBuilder<PhoneVerifyIntBloc, PhoneVerifyIntState>(
              builder: (_, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (widget, animation) {
                    final slideAnimation = Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation);

                    final fadeAnimation = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(animation);

                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: widget,
                      ),
                    );
                  },
                  child: getView(state.currentStep),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
