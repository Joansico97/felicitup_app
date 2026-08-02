import 'package:felicitup_app/core/constants/app_constants.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/invite/bloc/invite_bloc.dart';
import 'package:felicitup_app/features/felicitup_notification/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class InviteWebView extends StatelessWidget {
  const InviteWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Container(
          width: 500,
          margin: EdgeInsets.symmetric(vertical: context.sp(40)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.sp(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.sp(20)),
            child: BlocBuilder<InviteBloc, InviteState>(
              builder: (_, state) {
                final felicitup = state.currentFelicitup;

                if (state.isLoading || state.status == InviteStatus.loading) {
                  return Center(
                    child: CircularProgressIndicator(color: context.colors.orange),
                  );
                }

                if (felicitup == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(context.sp(20)),
                      child: Text(
                        'No se pudo cargar la información de la felicitup.',
                        textAlign: TextAlign.center,
                        style: context.styles.header2,
                      ),
                    ),
                  );
                }

                final listOwner = felicitup.owner;
                final invitedUsers = felicitup.invitedUserDetails;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: context.sp(60),
                        width: double.infinity,
                        color: context.colors.orange,
                        alignment: Alignment.center,
                        child: Text(
                          listOwner.length > 1
                              ? '${felicitup.reason} en Grupo'
                              : '${felicitup.reason} ${listOwner[0].name.split(' ')[0]}',
                          style: context.styles.header2.copyWith(
                            color: context.colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(context.sp(40)),
                        child: Column(
                          children: [
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
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: context.sp(10),
                              runSpacing: context.sp(10),
                              children: [
                                ...List.generate(
                                  invitedUsers.length,
                                  (index) => PersonCard(
                                    nameParticipant:
                                        invitedUsers[index].name ?? '',
                                    imageNetwork:
                                        invitedUsers[index].userImage ?? '',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.sp(40)),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: context.sp(10),
                              runSpacing: context.sp(10),
                              children: [
                                InfoCard(
                                  icon: Icons.calendar_today,
                                  label: DateFormat(
                                    AppConstants.birthDateFormat,
                                  ).format(felicitup.date),
                                ),
                                const InfoCard(
                                    icon: Icons.chat, label: 'Chat\nGrupo'),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
