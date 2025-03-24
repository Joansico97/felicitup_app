import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PeoplePastFelicitupPage extends StatefulWidget {
  const PeoplePastFelicitupPage({super.key});

  @override
  State<PeoplePastFelicitupPage> createState() => _PeoplePastFelicitupPageState();
}

class _PeoplePastFelicitupPageState extends State<PeoplePastFelicitupPage> {
  @override
  void initState() {
    super.initState();
    final felicitup = context.read<DetailsPastFelicitupDashboardBloc>().state.felicitup;
    context.read<PeoplePastFelicitupBloc>().add(PeoplePastFelicitupEvent.startListening(felicitup?.id ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsPastFelicitupDashboardBloc, DetailsPastFelicitupDashboardState>(
      builder: (_, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              context.go(RouterPaths.felicitupsDashboard);
            }
          },
          child: Scaffold(
            backgroundColor: context.colors.background,
            body: BlocBuilder<PeoplePastFelicitupBloc, PeoplePastFelicitupState>(
              builder: (_, state) {
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: context.sp(40),
                        width: context.sp(113),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(context.sp(20)),
                          color: context.colors.white,
                        ),
                        child: Text(
                          'Participantes',
                          style: context.styles.smallText.copyWith(
                            color: context.colors.softOrange,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.sp(22)),
                    BlocBuilder<PeoplePastFelicitupBloc, PeoplePastFelicitupState>(
                      builder: (_, state) {
                        final invitedUsers = state.invitedUsers;

                        return Expanded(
                          child: ListView.builder(
                            itemCount: invitedUsers?.length ?? 0,
                            itemBuilder: (_, index) => Column(
                              children: [
                                DetailsRow(
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
                                              : context.colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  sufixChild: SizedBox(),
                                ),
                                SizedBox(height: context.sp(12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
