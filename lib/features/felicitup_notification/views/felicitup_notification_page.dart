import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/felicitup_models/felicitup_models.dart';
import 'package:felicitup_app/features/felicitup_notification/bloc/felicitup_notification_bloc.dart';
import 'package:felicitup_app/features/felicitup_notification/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FelicitupNotificationPage extends StatelessWidget {
  const FelicitupNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;
    return BlocListener<FelicitupNotificationBloc, FelicitupNotificationState>(
      listenWhen: (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: BlocBuilder<FelicitupNotificationBloc, FelicitupNotificationState>(
        buildWhen: (previous, current) => previous.currentFelicitup != current.currentFelicitup,
        builder: (_, state) {
          final felicitup = state.currentFelicitup;

          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                // padding: EdgeInsets.symmetric(
                //   horizontal: context.sp(24),
                //   vertical: context.sp(12),
                // ),
                child: felicitup != null
                    ? Column(
                        children: [
                          Container(
                            height: context.sp(40),
                            width: context.fullWidth,
                            color: context.colors.orange,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  felicitup.owner.length > 1
                                      ? '${felicitup.reason} en Grupo'
                                      : '${felicitup.reason} ${felicitup.owner[0].name.split(' ')[0]}',
                                  style: context.styles.smallText.copyWith(
                                    color: context.colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: context.fullWidth,
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      IconButton(
                                        onPressed: () => context.go(RouterPaths.felicitupsDashboard),
                                        icon: Container(
                                          padding: EdgeInsets.all(context.sp(1)),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: context.colors.white,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            color: context.colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.sp(24)),
                          Image.asset(
                            Assets.images.logoLetter.path,
                            height: context.sp(62),
                          ),
                          SizedBox(height: context.sp(24)),
                          BlocBuilder<FelicitupNotificationBloc, FelicitupNotificationState>(
                            buildWhen: (previous, current) => previous.creator != current.creator,
                            builder: (_, state) {
                              final creator = state.creator;
                              return Text(
                                '${creator?.firstName ?? ''} te invita a participar en: ',
                                textAlign: TextAlign.center,
                                style: context.styles.subtitle,
                              );
                            },
                          ),
                          SizedBox(height: context.sp(24)),
                          Visibility(
                            visible: felicitup.owner.length > 1,
                            child: Column(
                              children: [
                                Text(
                                  '#FELICITUP-GRUPO',
                                  style: context.styles.subtitle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: context.sp(24)),
                              ],
                            ),
                          ),
                          Text(
                            '${felicitup.reason.toUpperCase()} DE',
                            style: context.styles.subtitle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: context.sp(24)),
                          BlocBuilder<FelicitupNotificationBloc, FelicitupNotificationState>(
                            buildWhen: (previous, current) => previous.currentFelicitup != current.currentFelicitup,
                            builder: (_, state) {
                              final listOwner = state.currentFelicitup?.owner ?? [];

                              return Wrap(
                                children: [
                                  ...List.generate(
                                    listOwner.length,
                                    (index) => index == listOwner.length - 1
                                        ? Text(
                                            '${listOwner[index].name} ',
                                            style: context.styles.subtitle,
                                          )
                                        : Text(
                                            'y ${listOwner[index].name} ',
                                            style: context.styles.subtitle,
                                          ),
                                  )
                                ],
                              );
                            },
                          ),
                          SizedBox(height: context.sp(24)),
                          Text(
                            'Participantes',
                            style: context.styles.subtitle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: context.sp(24)),
                          BlocBuilder<FelicitupNotificationBloc, FelicitupNotificationState>(
                            buildWhen: (previous, current) => previous.invitedUsers != current.invitedUsers,
                            builder: (_, state) {
                              final invitedUsers = state.invitedUsers;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...List.generate(
                                    invitedUsers?.length ?? 0,
                                    (index) => PersonCard(
                                      nameParticipant: invitedUsers?[index].firstName ?? '',
                                      imageNetwork: invitedUsers?[index].userImg ?? '',
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                          SizedBox(height: context.sp(24)),
                          SizedBox(
                            width: context.fullWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InfoCard(
                                  icon: Icons.calendar_today,
                                  label: '${felicitup.date.day}/${felicitup.date.month}/${felicitup.date.year}',
                                ),
                                const InfoCard(
                                  icon: Icons.chat,
                                  label: 'Chat\nGrupo',
                                ),
                                Visibility(
                                  visible: felicitup.hasVideo,
                                  child: const InfoCard(
                                    icon: Icons.videocam,
                                    label: 'Vídeo\nGrupo',
                                  ),
                                ),
                                Visibility(
                                  visible: felicitup.hasBote,
                                  child: InfoCard(
                                    icon: Icons.attach_money_outlined,
                                    label: 'Bote Regalo\n${felicitup.boteQuantity}€',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.sp(24)),
                          Text(
                            '¿Quieres participar?',
                            style: context.styles.header2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: context.sp(24)),
                          SizedBox(
                            width: context.sp(300),
                            child: Row(
                              children: [
                                Expanded(
                                  child: PrimaryButton(
                                    onTap: () {
                                      context.read<FelicitupNotificationBloc>().add(
                                            FelicitupNotificationEvent.informParticipation(
                                              felicitup.id,
                                              enumToStringAssistance(AssistanceStatus.accepted),
                                              currentUser?.firstName ?? '',
                                            ),
                                          );
                                      context.go(
                                        RouterPaths.messageFelicitup,
                                        extra: {
                                          'felicitupId': felicitup.id,
                                          'fromNotification': false,
                                        },
                                      );
                                    },
                                    label: 'SI',
                                    isActive: true,
                                    isCollapsed: true,
                                  ),
                                ),
                                SizedBox(width: context.sp(12)),
                                Expanded(
                                  child: PrimaryButton(
                                    onTap: () {
                                      context.read<FelicitupNotificationBloc>().add(
                                            FelicitupNotificationEvent.informParticipation(
                                              felicitup.id,
                                              enumToStringAssistance(AssistanceStatus.rejected),
                                              currentUser?.firstName ?? '',
                                            ),
                                          );
                                      context.go(RouterPaths.felicitupsDashboard);
                                    },
                                    label: 'NO',
                                    isActive: true,
                                    isCollapsed: true,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    : Center(
                        child: Text(
                          'Error cargando información',
                          style: context.styles.header2.copyWith(
                            color: context.colors.darkBlue,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
