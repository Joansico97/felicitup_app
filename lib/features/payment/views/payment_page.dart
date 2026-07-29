import 'dart:async';

import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/payment/bloc/payment_bloc.dart';
import 'package:felicitup_app/features/payment/views/mobile/payment_mobile_page.dart';
import 'package:felicitup_app/features/payment/views/web/payment_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:felicitup_app/core/router/router.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({
    super.key,
    required this.isVerify,
    required this.felicitup,
    required this.userId,
  });

  final bool isVerify;
  final FelicitupModel felicitup;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.updateStatus != current.updateStatus,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.updateStatus == UpdateStatus.success) {
          context.go(
            RouterPaths.boteFelicitup,
            extra: {'felicitupId': felicitup.id},
          );
        } else if (state.updateStatus == UpdateStatus.error) {
          await showErrorModal(state.errorMessage);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return PaymentWebPage(
              isVerify: isVerify,
              felicitup: felicitup,
              userId: userId,
            );
          }

          return PaymentMobilePage(
            isVerify: isVerify,
            felicitup: felicitup,
            userId: userId,
          );
        },
      ),
    );
  }
}
