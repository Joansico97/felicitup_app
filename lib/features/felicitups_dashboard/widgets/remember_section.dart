import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/create_felicitup/create_felicitup.dart';
import 'package:felicitup_app/features/felicitups_dashboard/felicitups_dashboard.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RememberSection extends StatelessWidget {
  const RememberSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDownBig(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: context.sp(192),
          minHeight: context.sp(50),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(26),
          vertical: context.sp(22),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.sp(20)),
          color: Colors.white.withAlpha((.4 * 255).toInt()),
          border: Border.all(
            color: Colors.white,
            width: context.sp(2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: context.sp(28),
              width: context.sp(119),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.sp(20)),
                color: Colors.white,
              ),
              child: Text(
                'Cumpleaños',
                style: context.styles.smallText.copyWith(
                  color: context.colors.softOrange,
                ),
              ),
            ),
            SizedBox(height: context.sp(8)),
            BlocBuilder<AppBloc, AppState>(
              builder: (_, state) {
                final currentUser = state.currentUser;

                return Column(
                  children: [
                    ...List.generate(
                      currentUser?.birthdateAlerts?.length ?? 0,
                      (index) {
                        final data = currentUser?.birthdateAlerts?[index];

                        return RememberCard(
                          name: data?.friendName ?? '',
                          date: DateTime.now(),
                          image: data?.friendProfilePic,
                          onTap: () {
                            showConfirDoublemModal(
                              title: 'Qué acción deseas realizar?',
                              label1: 'Crear felicitup para este usuario',
                              label2: 'Enviar mensaje directo',
                              onAction1: () async {
                                final OwnerModel owner = OwnerModel(
                                  id: data?.friendId ?? '',
                                  name: data?.friendName ?? '',
                                  userImg: data?.friendProfilePic,
                                  date: DateTime.now(),
                                );
                                context.go(RouterPaths.createFelicitup);
                                context.read<CreateFelicitupBloc>().add(
                                      CreateFelicitupEvent.changeFelicitupOwner(owner),
                                    );
                                context.read<CreateFelicitupBloc>().add(
                                      CreateFelicitupEvent.changeEventReason(
                                        'Cumpleaños',
                                      ),
                                    );
                                context.read<CreateFelicitupBloc>().add(CreateFelicitupEvent.jumpToStep(2));
                              },
                              onAction2: () async {
                                final SingleChatModel singleChat = SingleChatModel(
                                  chatId: data?.friendId ?? '',
                                  friendId: data?.friendId ?? '',
                                  userName: data?.friendName ?? '',
                                  userImage: data?.friendProfilePic,
                                );
                                context.read<FelicitupsDashboardBloc>().add(
                                      FelicitupsDashboardEvent.createSingleChat(singleChat),
                                    );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
