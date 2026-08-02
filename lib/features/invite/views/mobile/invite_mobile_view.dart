import 'package:felicitup_app/core/constants/app_constants.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/invite/bloc/invite_bloc.dart';
import 'package:felicitup_app/features/felicitup_notification/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class InviteMobileView extends StatelessWidget {
  const InviteMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<InviteBloc, InviteState>(
        builder: (_, state) {
          final felicitup = state.currentFelicitup;

          if (state.isLoading || state.status == InviteStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.orange),
            );
          }

          if (felicitup == null) {
            return Center(
              child: Text(
                'No se pudo cargar la información de la felicitup.',
                textAlign: TextAlign.center,
                style: context.styles.header2,
              ),
            );
          }

          final listOwner = felicitup.owner;
          final invitedUsers = felicitup.invitedUserDetails;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: context.sp(40),
                    width: context.fullWidth,
                    color: context.colors.orange,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          listOwner.length > 1
                              ? '${felicitup.reason} en Grupo'
                              : '${felicitup.reason} ${listOwner[0].name.split(' ')[0]}',
                          style: context.styles.smallText.copyWith(
                            color: context.colors.white,
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
                  Text(
                    'Has sido invitado a participar en: ',
                    textAlign: TextAlign.center,
                    style: context.styles.subtitle,
                  ),
                  SizedBox(height: context.sp(24)),
                  Visibility(
                    visible: listOwner.length > 1,
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
                  Wrap(
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
                      ),
                    ],
                  ),
                  SizedBox(height: context.sp(24)),
                  Text(
                    'Participantes',
                    style: context.styles.subtitle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.sp(24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                        invitedUsers.length,
                        (index) => PersonCard(
                          nameParticipant:
                              invitedUsers[index].name ?? '',
                          imageNetwork: invitedUsers[index].userImage ?? '',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.sp(24)),
                  SizedBox(
                    width: context.fullWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InfoCard(
                          icon: Icons.calendar_today,
                          label: DateFormat(
                            AppConstants.birthDateFormat,
                          ).format(felicitup.date),
                        ),
                        const InfoCard(icon: Icons.chat, label: 'Chat\nGrupo'),
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
                  SizedBox(height: context.sp(40)),
                  SizedBox(
                    width: context.sp(300),
                    child: PrimaryButton(
                      onTap: () {
                        context.read<InviteBloc>().add(
                              const InviteEvent.joinFelicitup(),
                            );
                      },
                      label: 'Unirse a la Felicitup',
                      isActive: true,
                      isCollapsed: true,
                    ),
                  ),
                  SizedBox(height: context.sp(40)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
