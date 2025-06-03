import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(
      NotificationsEvent.getNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listenWhen:
          (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: context.sp(50),
                width: context.fullWidth,
                padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: context.fullWidth,
                      child: Text(
                        'Notificaciones',
                        textAlign: TextAlign.center,
                        style: context.styles.subtitle,
                      ),
                    ),
                    Container(
                      width: context.fullWidth,
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          if (context.mounted) {
                            context.go(RouterPaths.felicitupsDashboard);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.sp(12)),
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (_, state) {
                  final notifications = List.of(state.notifications)..sort(
                    (a, b) => (a.sentDate ?? DateTime(0)).compareTo(
                      b.sentDate ?? DateTime(0),
                    ),
                  );

                  return Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
                      itemCount: notifications.length,
                      itemBuilder: (_, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: context.sp(12),
                            vertical: context.sp(8),
                          ),
                          title: Text(
                            notifications[index].title ?? '',
                            style: context.styles.smallText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notifications[index].body ?? '',
                                style: context.styles.paragraph,
                              ),
                              SizedBox(height: context.sp(4)),
                              SizedBox(
                                width: context.sp(350),
                                child: Text(
                                  'Recibido el: ${DateFormat('dd/MM/yyyy HH:mm').format(notifications[index].sentDate ?? DateTime.now())}',
                                  textAlign: TextAlign.end,
                                  style: context.styles.smallText.copyWith(
                                    color: context.colors.darkGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            redirectHelper(
                              data: notifications[index].data?.toJson() ?? {},
                            );
                          },
                          // onLongPress: () {
                          //   showConfirmModal(
                          //     title: 'Deseas eliminar la notificación?',
                          //     onAccept: () async {
                          //       context.read<NotificationsBloc>().add(
                          //         NotificationsEvent.deleteNotification(
                          //           notifications[index].messageId ?? '',
                          //         ),
                          //       );
                          //     },
                          //   );
                          // },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
