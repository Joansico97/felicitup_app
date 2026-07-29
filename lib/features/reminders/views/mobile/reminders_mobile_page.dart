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

class RemindersMobilePage extends StatelessWidget {
  const RemindersMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CollapsedHeader(
              title: context.locale.reminders_title,
              onPressed: () async =>
                  context.go(RouterPaths.felicitupsDashboard),
            ),
            SizedBox(height: context.sp(12)),
            Expanded(
              child: BlocBuilder<AppBloc, AppState>(
                buildWhen: (previous, current) =>
                    previous.currentUser != current.currentUser,
                builder: (_, state) {
                  final currentUser = state.currentUser;
                  final birthdateAlerts = state.currentUser?.birthdateAlerts
                      ?.where(
                        (alert) => alert.targetDate!.isAfter(
                          DateTime.now().subtract(const Duration(days: 1)),
                        ),
                      )
                      .toList();

                  if (birthdateAlerts == null || birthdateAlerts.isEmpty) {
                    return Center(
                      child: Text(
                        context.locale.no_reminders,
                        style: context.styles.paragraph,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
                    itemCount: birthdateAlerts.length,
                    itemBuilder: (_, index) {
                      final data = birthdateAlerts[index];

                      return RememberCard(
                        userId: data.friendId ?? '123456789',
                        name: data.getDisplayName(currentUser),
                        date: data.targetDate!,
                        image: data.friendProfilePic,
                        onTap: () => showConfirDoublemModal(
                          needOtherButton: true,
                          title: context.locale.reminder_action_title,
                          label1: context.locale.create_felicitup_for_user,
                          label2: context.locale.send_direct_message,
                          label3: context.locale.delete_reminder,
                          onAction1: () async {
                            final OwnerModel owner = OwnerModel(
                              id: data.friendId ?? '',
                              name: data.getDisplayName(currentUser),
                              userImg: data.friendProfilePic,
                              date: data.targetDate!,
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
                                  const CreateFelicitupEvent.changeEventReason(
                                    'Cumpleaños',
                                  ),
                                );
                            context.read<RemindersBloc>().add(
                              RemindersEvent.deleteBirthdateAlert(
                                data.id ?? '',
                              ),
                            );
                            rootNavigatorKey.currentContext!
                                .read<CreateFelicitupBloc>()
                                .add(const CreateFelicitupEvent.jumpToStep(2));
                          },
                          onAction2: () async {
                            final SingleChatModel singleChat = SingleChatModel(
                              chatId: data.friendId ?? '',
                              friendId: data.friendId ?? '',
                              userName: data.friendName ?? '',
                              userImage: data.friendProfilePic,
                            );
                            if (currentUser?.singleChats?.any(
                                  (alert) => alert.friendId == data.friendId,
                                ) ??
                                false) {
                              final alert = currentUser?.singleChats
                                  ?.firstWhere(
                                    (alert) => alert.friendId == data.friendId,
                                  );
                              context.go(RouterPaths.singleChat, extra: alert);
                              return;
                            }

                            context.read<RemindersBloc>().add(
                              RemindersEvent.deleteBirthdateAlert(
                                data.id ?? '',
                              ),
                            );
                            context.read<RemindersBloc>().add(
                              RemindersEvent.createSingleChat(singleChat),
                            );
                          },
                          onAction3: () async =>
                              context.read<RemindersBloc>().add(
                                RemindersEvent.deleteBirthdateAlert(
                                  data.id ?? '',
                                ),
                              ),
                        ),
                      );
                    },
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
