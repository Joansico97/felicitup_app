import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/contact_card_row.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PeopleFelicitupPage extends StatefulWidget {
  const PeopleFelicitupPage({super.key});

  @override
  State<PeopleFelicitupPage> createState() => _PeopleFelicitupPageState();
}

class _PeopleFelicitupPageState extends State<PeopleFelicitupPage> {
  List<bool> isSelected = [];
  @override
  void initState() {
    super.initState();
    detailsFelicitupNavigatorKey.currentContext!
        .read<DetailsFelicitupDashboardBloc>()
        .add(DetailsFelicitupDashboardEvent.changeCurrentIndex(2));
    final felicitup =
        context.read<DetailsFelicitupDashboardBloc>().state.felicitup;
    context.read<PeopleFelicitupBloc>().add(
      PeopleFelicitupEvent.startListening(felicitup?.id ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      DetailsFelicitupDashboardBloc,
      DetailsFelicitupDashboardState
    >(
      buildWhen: (previous, current) => previous.felicitup != current.felicitup,
      builder: (_, state) {
        final felicitup = state.felicitup;
        final currentUser = context.read<AppBloc>().state.currentUser;

        return Scaffold(
          backgroundColor: context.colors.background,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (felicitup!.createdBy == currentUser!.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BlocBuilder<PeopleFelicitupBloc, PeopleFelicitupState>(
                        buildWhen:
                            (previous, current) =>
                                previous.invitedContacts !=
                                current.invitedContacts,
                        builder: (_, state) {
                          final friendList = [...state.friendList];
                          friendList.removeWhere(
                            (friend) => felicitup.owner.any(
                              (owner) => owner.id == friend.id,
                            ),
                          );
                          friendList.removeWhere(
                            (friend) => felicitup.invitedUsers.any(
                              (invitedUser) => invitedUser == friend.id,
                            ),
                          );
                          isSelected = List.generate(
                            friendList.length,
                            (index) => false,
                          );

                          return FloatingActionButton.extended(
                            onPressed: () {
                              commoBottomModal(
                                context: rootNavigatorKey.currentContext!,
                                hasBottomButton: true,
                                onTap: () {
                                  context.read<PeopleFelicitupBloc>().add(
                                    PeopleFelicitupEvent.updateParticipantsList(
                                      felicitup.id,
                                    ),
                                  );
                                  context.pop();
                                },
                                body: BlocProvider.value(
                                  value: context.read<PeopleFelicitupBloc>(),
                                  child: Column(
                                    children: [
                                      ...List.generate(
                                        friendList.length,
                                        (index) => GestureDetector(
                                          onTap: () {
                                            isSelected[index] =
                                                !isSelected[index];
                                            final participant = InvitedModel(
                                              id: friendList[index].id ?? '',
                                              name:
                                                  friendList[index].fullName ??
                                                  '',
                                              userImage:
                                                  friendList[index].userImg ??
                                                  '',
                                              assistanceStatus:
                                                  enumToStringAssistance(
                                                    AssistanceStatus.pending,
                                                  ),
                                              paid: enumToStringPayment(
                                                PaymentStatus.pending,
                                              ),
                                              videoData: VideoDataModel(
                                                videoUrl: '',
                                                videoThumbnail: '',
                                              ),
                                              idInformation: '',
                                            );
                                            context.read<PeopleFelicitupBloc>().add(
                                              PeopleFelicitupEvent.addParticipant(
                                                participant,
                                              ),
                                            );
                                          },
                                          child: BlocBuilder<
                                            PeopleFelicitupBloc,
                                            PeopleFelicitupState
                                          >(
                                            builder: (_, state) {
                                              return ContactCardRow(
                                                contact: friendList[index],
                                                isSelected: state
                                                    .invitedContacts
                                                    .any(
                                                      (user) =>
                                                          user.id ==
                                                          friendList[index].id,
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            backgroundColor: context.colors.orange,
                            label: Row(
                              children: [
                                Icon(
                                  Icons.person_add,
                                  color: context.colors.white,
                                ),
                                SizedBox(width: context.sp(6)),
                                Text(
                                  'Agregar',
                                  style: context.styles.smallText.copyWith(
                                    color: context.colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
                        GestureDetector(
                          onTap: () {
                            if (invitedUsers?[index].id == currentUser.id &&
                                felicitup.createdBy != currentUser.id) {
                              showConfirDoublemModal(
                                title: 'Participarás en la felicitup?',
                                label1: 'Confirmar',
                                isDestructive: true,
                                onAction1:
                                    invitedUsers?[index].assistanceStatus ==
                                            enumToStringAssistance(
                                              AssistanceStatus.accepted,
                                            )
                                        ? () async {
                                          context.pop();
                                        }
                                        : () async => context
                                            .read<PeopleFelicitupBloc>()
                                            .add(
                                              PeopleFelicitupEvent.informParticipation(
                                                felicitupId: felicitup.id,
                                                felicitupOwnerId:
                                                    felicitup.createdBy,
                                                newStatus:
                                                    enumToStringAssistance(
                                                      AssistanceStatus.accepted,
                                                    ),
                                                name:
                                                    currentUser.firstName ?? '',
                                              ),
                                            ),
                                label2: 'Denegar',
                                onAction2: () async {
                                  context.read<PeopleFelicitupBloc>().add(
                                    PeopleFelicitupEvent.informParticipation(
                                      felicitupId: felicitup.id,
                                      felicitupOwnerId: felicitup.createdBy,
                                      newStatus: enumToStringAssistance(
                                        AssistanceStatus.rejected,
                                      ),
                                      name: currentUser.firstName ?? '',
                                    ),
                                  );
                                  context.go(RouterPaths.felicitupsDashboard);
                                },
                              );
                            }
                          },
                          onLongPress: () {
                            if (felicitup.createdBy == currentUser.id &&
                                invitedUsers?[index].id != currentUser.id) {
                              showConfirDoublemModal(
                                title: 'Eliminar participante?',
                                label1: 'Eliminar',
                                isDestructive: true,
                                onAction1: () async {
                                  context.read<PeopleFelicitupBloc>().add(
                                    PeopleFelicitupEvent.deleteParticipant(
                                      felicitup.id,
                                      invitedUsers?[index].id ?? '',
                                    ),
                                  );
                                  // context.pop();
                                },
                                label2: 'Cancelar',
                                onAction2: () async {
                                  context.pop();
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
                                    invitedUsers?[index].name![0]
                                            .toUpperCase() ??
                                        '',
                                    style: context.styles.subtitle,
                                  ),
                                ),
                                SizedBox(width: context.sp(14)),
                                Text(
                                  invitedUsers?[index].name ?? '',
                                  style: context.styles.smallText.copyWith(
                                    color:
                                        invitedUsers?[index].assistanceStatus ==
                                                enumToStringAssistance(
                                                  AssistanceStatus.pending,
                                                )
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
                                color:
                                    invitedUsers?[index].assistanceStatus ==
                                            enumToStringAssistance(
                                              AssistanceStatus.accepted,
                                            )
                                        ? context.colors.softOrange
                                        : context.colors.otherGrey,
                              ),
                              child: Icon(
                                Icons.check,
                                color:
                                    invitedUsers?[index].assistanceStatus ==
                                            enumToStringAssistance(
                                              AssistanceStatus.accepted,
                                            )
                                        ? Colors.white
                                        : context.colors.otherGrey,
                                size: 11,
                              ),
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
