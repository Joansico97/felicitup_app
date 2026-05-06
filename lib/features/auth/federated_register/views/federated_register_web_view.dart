import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/auth/federated_register/bloc/federated_register_bloc.dart';
import 'package:felicitup_app/features/auth/federated_register/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FederatedRegisterWebView extends StatelessWidget {
  const FederatedRegisterWebView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget getView(int index) {
      switch (index) {
        case 0:
          return const FormFederatedView();
        case 1:
          return const PhoneFederatedView();
        case 2:
          return const ValidateCodeFederatedView();
        case 3:
          return const FinishRegisterFederatedView();
        default:
          return const FormFederatedView();
      }
    }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 100,
                ),
                child: Center(
                  child: SizedBox(
                    width: 400,
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(size: const Size(393, 852)),
                      child:
                          BlocBuilder<
                            FederatedRegisterBloc,
                            FederatedRegisterState
                          >(
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
                                child: getView(state.currentIndex),
                              );
                            },
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
