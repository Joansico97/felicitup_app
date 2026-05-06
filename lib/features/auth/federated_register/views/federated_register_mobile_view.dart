import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/auth/federated_register/bloc/federated_register_bloc.dart';
import 'package:felicitup_app/features/auth/federated_register/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FederatedRegisterMobileView extends StatelessWidget {
  const FederatedRegisterMobileView({super.key});

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                height: context.fullHeight,
                width: context.fullWidth,
                padding: EdgeInsets.symmetric(vertical: context.sp(12)),
                child:
                    BlocBuilder<FederatedRegisterBloc, FederatedRegisterState>(
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
          ],
        ),
      ),
    );
  }
}
