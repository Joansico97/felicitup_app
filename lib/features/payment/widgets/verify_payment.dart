import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/payment/bloc/payment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VerifyPayment extends StatefulWidget {
  const VerifyPayment({
    super.key,
    required this.felicitup,
    required this.userId,
  });

  final FelicitupModel felicitup;
  final String userId;

  @override
  State<VerifyPayment> createState() => _VerifyPaymentState();
}

class _VerifyPaymentState extends State<VerifyPayment> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(PaymentEvent.getUserInformation(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: context.sp(40),
                width: context.sp(113),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.sp(20)),
                  color: context.colors.white,
                ),
                child: Text(
                  'Bote regalo',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.softOrange,
                  ),
                ),
              ),
              Spacer(),
              Container(
                height: context.sp(40),
                width: context.sp(55),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.sp(20)),
                  color: context.colors.white,
                ),
                child: Text(
                  '${widget.felicitup.boteQuantity}€',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.softOrange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(24)),
          Container(
            padding: EdgeInsets.all(context.sp(24)),
            decoration: BoxDecoration(
              color: context.colors.white,
              borderRadius: BorderRadius.circular(context.sp(20)),
            ),
            child: Column(
              children: [
                Container(
                  height: context.sp(40),
                  width: context.fullWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(10),
                    vertical: context.sp(8),
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.sp(30)),
                    border: Border.all(
                      color: context.colors.darkGrey,
                      width: context.sp(1),
                    ),
                    color: context.colors.white,
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Estado de pago: ',
                      style: context.styles.paragraph.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'A la espera',
                          style: context.styles.paragraph,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.sp(14)),
                Container(
                  height: context.sp(40),
                  width: context.fullWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(10),
                    vertical: context.sp(8),
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.sp(30)),
                    border: Border.all(
                      color: context.colors.darkGrey,
                      width: context.sp(1),
                    ),
                    color: context.colors.white,
                  ),
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (_, state) {
                      return RichText(
                        text: TextSpan(
                          text: 'Fecha de pago: ',
                          style: context.styles.paragraph.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: DateFormat('dd/MM/yyyy').format(
                                state.userInvitedInformationModel?.paymentDate ?? DateTime.now(),
                              ),
                              style: context.styles.paragraph,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.sp(14)),
                Container(
                  height: context.sp(40),
                  width: context.fullWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(10),
                    vertical: context.sp(8),
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.sp(30)),
                    border: Border.all(
                      color: context.colors.darkGrey,
                      width: context.sp(1),
                    ),
                    color: context.colors.white,
                  ),
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (_, state) {
                      return RichText(
                        text: TextSpan(
                          text: 'Medio de pago: ',
                          style: context.styles.paragraph.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: state.userInvitedInformationModel?.paymentMethod ?? 'No disponible',
                              style: context.styles.paragraph,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.sp(14)),
                GestureDetector(
                  onTap: () => showImageModal(
                    context,
                    context.read<PaymentBloc>().state.userInvitedInformationModel?.photoUrl ?? '',
                  ),
                  child: Container(
                    height: context.sp(350),
                    width: context.fullWidth,
                    padding: EdgeInsets.all(context.sp(10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.sp(30)),
                      border: Border.all(
                        color: context.colors.darkGrey,
                        width: context.sp(1),
                      ),
                      color: context.colors.white,
                    ),
                    child: BlocBuilder<PaymentBloc, PaymentState>(
                      builder: (_, state) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(context.sp(30)),
                          child: Image.network(
                            state.userInvitedInformationModel?.photoUrl ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: context.sp(14)),
                SizedBox(
                  width: context.sp(300),
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (_, state) {
                      return PrimaryButton(
                        onTap: () => context.read<PaymentBloc>().add(
                              PaymentEvent.confirmPaymentInfo(
                                widget.felicitup.id,
                                state.userInvitedInformationModel?.id ?? '',
                              ),
                            ),
                        label: 'Confirmar pago',
                        isActive: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
