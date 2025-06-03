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

class RememberSection extends StatefulWidget {
  const RememberSection({super.key});

  @override
  State<RememberSection> createState() => _RememberSectionState();
}

class _RememberSectionState extends State<RememberSection> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return FadeInDownBig(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isCollapsed = !isCollapsed;
          });
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight: isCollapsed ? context.sp(80) : context.sp(192),
            minHeight: context.sp(50),
            maxWidth: context.sp(310),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(26),
            vertical: context.sp(22),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.sp(20)),
            color: Colors.white.withAlpha((.4 * 255).toInt()),
            border: Border.all(color: Colors.white, width: context.sp(2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
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
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(context.sp(4)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.white,
                    ),
                    child: Icon(
                      isCollapsed
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: context.colors.orange,
                      size: context.sp(18),
                    ),
                  ),
                  SizedBox(width: context.sp(12)),
                  GestureDetector(
                    onTap:
                        () => context.read<AppBloc>().add(
                          AppEvent.closeRememberSection(),
                        ),
                    child: Container(
                      padding: EdgeInsets.all(context.sp(4)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.white,
                      ),
                      child: Icon(
                        Icons.close,
                        color: context.colors.orange,
                        size: context.sp(18),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: !isCollapsed,
                child: SizedBox(height: context.sp(8)),
              ),
              Visibility(
                visible: !isCollapsed,
                child: BlocBuilder<AppBloc, AppState>(
                  builder: (_, state) {
                    final currentUser = state.currentUser;
                    final birthdateAlerts =
                        currentUser?.birthdateAlerts
                            ?.where(
                              (alert) => alert.targetDate!.isAfter(
                                DateTime.now().subtract(
                                  const Duration(days: 1),
                                ),
                              ),
                            )
                            .toList();

                    return Expanded(
                      child: ListView.builder(
                        itemCount: birthdateAlerts?.length ?? 0,
                        itemBuilder: (_, index) {
                          final data = birthdateAlerts?[index];

                          return RememberCard(
                            name: data?.friendName ?? '',
                            date: data?.targetDate ?? DateTime.now(),
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
                                    date: data?.targetDate ?? DateTime.now(),
                                  );
                                  context.go(RouterPaths.createFelicitup);
                                  context.read<CreateFelicitupBloc>().add(
                                    CreateFelicitupEvent.changeFelicitupOwner(
                                      owner,
                                    ),
                                  );
                                  context.read<CreateFelicitupBloc>().add(
                                    CreateFelicitupEvent.changeEventReason(
                                      'Cumpleaños',
                                    ),
                                  );
                                  context.read<CreateFelicitupBloc>().add(
                                    CreateFelicitupEvent.jumpToStep(2),
                                  );

                                  context.read<FelicitupsDashboardBloc>().add(
                                    FelicitupsDashboardEvent.deleteBirthdateAlert(
                                      data?.id ?? '',
                                    ),
                                  );
                                },
                                onAction2: () async {
                                  final SingleChatModel singleChat =
                                      SingleChatModel(
                                        chatId: data?.friendId ?? '',
                                        friendId: data?.friendId ?? '',
                                        userName: data?.friendName ?? '',
                                        userImage: data?.friendProfilePic,
                                      );
                                  if (currentUser?.singleChats?.any(
                                        (alert) =>
                                            alert.friendId == data?.friendId,
                                      ) ??
                                      false) {
                                    final alert = currentUser?.singleChats
                                        ?.firstWhere(
                                          (alert) =>
                                              alert.friendId == data?.friendId,
                                        );
                                    context.go(
                                      RouterPaths.singleChat,
                                      extra: alert,
                                    );
                                    return;
                                  }
                                  context.read<FelicitupsDashboardBloc>().add(
                                    FelicitupsDashboardEvent.createSingleChat(
                                      singleChat,
                                    ),
                                  );

                                  context.read<FelicitupsDashboardBloc>().add(
                                    FelicitupsDashboardEvent.deleteBirthdateAlert(
                                      data?.id ?? '',
                                    ),
                                  );
                                },
                              );
                            },
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
      ),
    );
  }
}
