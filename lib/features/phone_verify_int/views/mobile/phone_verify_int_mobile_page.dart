import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/phone_verify_int/phone_verify_int.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneVerifyIntMobilePage extends StatelessWidget {
  const PhoneVerifyIntMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget getView(int index) {
      switch (index) {
        case 0:
          return const GetPhoneView();
        case 1:
          return const ValidateSmsCodeView();
        default:
          return const GetPhoneView();
      }
    }

    return Scaffold(
      backgroundColor: context.colors.background,
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
    );
  }
}
