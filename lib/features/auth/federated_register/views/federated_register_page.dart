import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/federated_register/bloc/federated_register_bloc.dart';
import 'package:felicitup_app/features/auth/federated_register/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FederatedRegisterPage extends StatelessWidget {
  const FederatedRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    getView(int index) {
      switch (index) {
        case 0:
          return FormFederatedView();
        case 1:
          return PhoneFederatedView();
        case 2:
          return ValidateCodeFederatedView();
        case 3:
          return FinishRegisterFederatedView();
        default:
          return FormFederatedView();
      }
    }

    return BlocListener<FederatedRegisterBloc, FederatedRegisterState>(
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(60),
                    vertical: context.sp(12),
                  ),
                  child: BlocBuilder<FederatedRegisterBloc, FederatedRegisterState>(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
