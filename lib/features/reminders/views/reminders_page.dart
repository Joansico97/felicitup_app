import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/remember_card.dart';
import 'package:felicitup_app/features/reminders/reminders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CollapsedHeader(
              title: 'Recordatorios',
              onPressed:
                  () async => context.go(RouterPaths.felicitupsDashboard),
            ),
            SizedBox(height: context.sp(12)),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
                itemCount: currentUser?.birthdateAlerts?.length ?? 0,
                itemBuilder: (_, index) {
                  final data = currentUser?.birthdateAlerts?[index];
                  return RememberCard(
                    name: data?.friendName ?? 'Jorge Silva',
                    date: data?.targetDate ?? DateTime.now(),
                    image: data?.friendProfilePic,
                    onTap:
                        () => showConfirDoublemModal(
                          title: 'Qué acción deseas realizar?',

                          label1: 'Crear felicitup',
                          label2: 'Enviar mensaje directo',

                          onAction1: () async {
                            final OwnerModel owner = OwnerModel(
                              id: data?.friendId ?? '',
                              name: data?.friendName ?? '',
                              userImg: data?.friendProfilePic,
                              date: DateTime.now(),
                            );
                            context.go(RouterPaths.createFelicitup);
                            rootNavigatorKey.currentContext!
                                .read<CreateFelicitupBloc>()
                                .add(
                                  CreateFelicitupEvent.changeFelicitupOwner(
                                    owner,
                                  ),
                                );
                            rootNavigatorKey.currentContext!
                                .read<CreateFelicitupBloc>()
                                .add(
                                  CreateFelicitupEvent.changeEventReason(
                                    'Cumpleaños',
                                  ),
                                );
                            rootNavigatorKey.currentContext!
                                .read<CreateFelicitupBloc>()
                                .add(CreateFelicitupEvent.jumpToStep(2));

                            context.read<RemindersBloc>().add(
                              RemindersEvent.deleteBirthdateAlert(
                                data?.id ?? '',
                              ),
                            );
                          },
                          onAction2: () async {
                            final SingleChatModel singleChat = SingleChatModel(
                              chatId: data?.friendId ?? '',
                              friendId: data?.friendId ?? '',
                              userName: data?.friendName ?? '',
                              userImage: data?.friendProfilePic,
                            );
                            if (currentUser?.singleChats?.any(
                                  (alert) => alert.friendId == data?.friendId,
                                ) ??
                                false) {
                              final alert = currentUser?.singleChats
                                  ?.firstWhere(
                                    (alert) => alert.friendId == data?.friendId,
                                  );
                              context.go(RouterPaths.singleChat, extra: alert);
                              return;
                            }

                            context.read<RemindersBloc>().add(
                              RemindersEvent.createSingleChat(singleChat),
                            );
                            context.read<RemindersBloc>().add(
                              RemindersEvent.deleteBirthdateAlert(
                                data?.id ?? '',
                              ),
                            );
                          },
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
