import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BoteFelicitupPage extends StatefulWidget {
  const BoteFelicitupPage({super.key});

  @override
  State<BoteFelicitupPage> createState() => _BoteFelicitupPageState();
}

class _BoteFelicitupPageState extends State<BoteFelicitupPage> {
  @override
  void initState() {
    super.initState();
    final felicitup = context.read<DetailsFelicitupDashboardBloc>().state.felicitup;
    context.read<BoteFelicitupBloc>().add(BoteFelicitupEvent.startListening(felicitup?.id ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
      buildWhen: (previous, current) => previous.felicitup != current.felicitup,
      builder: (_, state) {
        final felicitup = state.felicitup;
        final currentUser = context.read<AppBloc>().state.currentUser;

        return Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
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
                  BlocBuilder<BoteFelicitupBloc, BoteFelicitupState>(
                    builder: (_, state) {
                      return GestureDetector(
                        onTap: felicitup?.createdBy == currentUser?.id ? () {} : null,
                        child: Container(
                          height: context.sp(40),
                          width: context.sp(55),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(context.sp(20)),
                            color: Colors.white,
                          ),
                          child: Text(
                            state.boteQuantity != null ? '${state.boteQuantity}€' : '${felicitup?.boteQuantity}€',
                            style: context.styles.smallText.copyWith(
                              color: context.colors.softOrange,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: context.sp(22)),
              BlocBuilder<BoteFelicitupBloc, BoteFelicitupState>(
                builder: (_, state) {
                  final invitedUsers = state.invitedUsers;

                  return Column(
                    children: [
                      ...List.generate(
                        invitedUsers?.length ?? 0,
                        (index) => Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (invitedUsers?[index].paid == enumToStringPayment(PaymentStatus.pending) &&
                                    invitedUsers?[index].id == currentUser?.id) {
                                  context.go(
                                    RouterPaths.payment,
                                    extra: {
                                      'isVerify': false,
                                      'felicitup': felicitup,
                                    },
                                  );
                                  //   context.read<BoteFelicitupBloc>().add(BoteFelicitupEvent.updatePayment(
                                  //     invitedUsers?[index].id ?? '',
                                  //     PaymentStatus.paid,
                                  //   ));
                                  // } else if (invitedUsers?[index].paid == enumToStringPayment(PaymentStatus.paid)) {
                                  //   context.read<BoteFelicitupBloc>().add(BoteFelicitupEvent.updatePayment(
                                  //     invitedUsers?[index].id ?? '',
                                  //     PaymentStatus.waiting,
                                  //   ));
                                }
                                if (invitedUsers?[index].paid == enumToStringPayment(PaymentStatus.waiting) &&
                                    felicitup?.createdBy == currentUser?.id) {
                                  context.go(
                                    RouterPaths.payment,
                                    extra: {
                                      'isVerify': true,
                                      'felicitup': felicitup,
                                      'userId': invitedUsers?[index].idInformation,
                                    },
                                  );
                                }
                              },
                              child: DetailsRow(
                                prefixChild: Row(
                                  children: [
                                    Container(
                                      height: context.sp(23),
                                      width: context.sp(23),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: context.colors.lightGrey,
                                      ),
                                      child: Text(
                                        invitedUsers?[index].name![0].toUpperCase() ?? '',
                                        style: context.styles.subtitle,
                                      ),
                                    ),
                                    SizedBox(width: context.sp(14)),
                                    Text(
                                      invitedUsers?[index].name ?? '',
                                      style: context.styles.smallText.copyWith(
                                        color: invitedUsers?[index].assistanceStatus ==
                                                enumToStringAssistance(AssistanceStatus.pending)
                                            ? context.colors.text
                                            : context.colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                sufixChild: Container(
                                  padding: EdgeInsets.all(context.sp(5)),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: invitedUsers?[index].paid == enumToStringPayment(PaymentStatus.paid)
                                        ? Colors.lightGreen
                                        : invitedUsers?[index].paid == enumToStringPayment(PaymentStatus.waiting)
                                            ? context.colors.softOrange
                                            : context.colors.otherGrey,
                                  ),
                                  child: Icon(
                                    Icons.euro,
                                    color: invitedUsers?[index].paid == enumToStringPayment(PaymentStatus.paid) ||
                                            invitedUsers?[index].paid == enumToStringPayment(PaymentStatus.waiting)
                                        ? Colors.white
                                        : context.colors.darkGrey,
                                    size: context.sp(11),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: context.sp(12)),
                          ],
                        ),
                      )
                    ],
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
