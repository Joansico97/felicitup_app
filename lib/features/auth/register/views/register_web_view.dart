import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/auth/register/bloc/register_bloc.dart';
import 'package:felicitup_app/features/auth/register/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterWebView extends StatelessWidget {
  const RegisterWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: context.fullHeight,
        width: context.fullWidth,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -70,
                left: -70,
                child: Container(
                  height: 170,
                  width: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.darkBlue,
                  ),
                ),
              ),
              Positioned(
                top: -110,
                right: -110,
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.orange,
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  height: 350,
                  width: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEE775A),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Center(
                    child: SizedBox(
                      width: 400,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: const Size(393, 852),
                        ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
