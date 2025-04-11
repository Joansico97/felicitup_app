import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/bloc/details_felicitup_dashboard_bloc.dart';
import 'package:felicitup_app/features/payment/bloc/payment_bloc.dart';
import 'package:felicitup_app/features/payment/widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key, required this.isVerify, required this.felicitup, required this.userId});

  final bool isVerify;
  final FelicitupModel felicitup;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listenWhen:
          (previous, current) =>
              previous.isLoading != current.isLoading || previous.updateStatus != current.updateStatus,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.updateStatus == UpdateStatus.success) {
          context.go(RouterPaths.boteFelicitup, extra: {'felicitupId': felicitup.id});
        } else if (state.updateStatus == UpdateStatus.error) {
          await showErrorModal(state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: context.sp(50),
                  width: context.fullWidth,
                  padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: context.fullWidth,
                        child: Text(
                          '${felicitup.reason} de ${felicitup.owner[0].name.split(' ')[0]}',
                          textAlign: TextAlign.center,
                          style: context.styles.subtitle,
                        ),
                      ),
                      Container(
                        width: context.fullWidth,
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                          onPressed: () async {
                            if (context.mounted) {
                              context.go(RouterPaths.boteFelicitup, extra: {'felicitupId': felicitup.id});
                              detailsFelicitupNavigatorKey.currentContext!.read<DetailsFelicitupDashboardBloc>().add(
                                DetailsFelicitupDashboardEvent.changeCurrentIndex(3),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.sp(12)),
                isVerify ? VerifyPayment(felicitup: felicitup, userId: userId) : ConfirmPayment(felicitup: felicitup),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
