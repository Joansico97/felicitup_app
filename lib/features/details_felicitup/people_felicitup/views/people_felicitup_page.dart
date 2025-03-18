import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/bloc/details_felicitup_dashboard_bloc.dart';
import 'package:felicitup_app/features/details_felicitup/people_felicitup/bloc/people_felicitup_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PeopleFelicitupPage extends StatefulWidget {
  const PeopleFelicitupPage({super.key});

  @override
  State<PeopleFelicitupPage> createState() => _PeopleFelicitupPageState();
}

class _PeopleFelicitupPageState extends State<PeopleFelicitupPage> {
  @override
  void initState() {
    super.initState();
    final felicitup = context.read<DetailsFelicitupDashboardBloc>().state.felicitup;
    context.read<PeopleFelicitupBloc>().add(PeopleFelicitupEvent.startListening(felicitup?.id ?? ''));
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
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (felicitup!.createdBy == currentUser!.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: () {},
                        backgroundColor: context.colors.orange,
                        child: Icon(
                          Icons.person_add,
                          color: context.colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          body: BlocBuilder<PeopleFelicitupBloc, PeopleFelicitupState>(
            builder: (_, state) {
              final invitedUsers = state.invitedUsers;

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
                  ...List.generate(
                    invitedUsers?.length ?? 0,
                    (index) => Column(
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
                                      : context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                          sufixChild: Container(
                            padding: EdgeInsets.all(context.sp(5)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: invitedUsers?[index].assistanceStatus ==
                                      enumToStringAssistance(AssistanceStatus.accepted)
                                  ? context.colors.softOrange
                                  : context.colors.otherGrey,
                            ),
                            child: Icon(
                              Icons.check,
                              color: invitedUsers?[index].assistanceStatus ==
                                      enumToStringAssistance(AssistanceStatus.accepted)
                                  ? Colors.white
                                  : context.colors.otherGrey,
                              size: 11,
                            ),
                          ),
                        ),
                        SizedBox(height: context.sp(12)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
