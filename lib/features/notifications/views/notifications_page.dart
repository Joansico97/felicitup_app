import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(NotificationsEvent.getNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listenWhen: (previous, current) => previous.isLoading != current.isLoading,
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
                padding: EdgeInsets.symmetric(
                  horizontal: context.sp(12),
                ),
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
                            context.go(
                              RouterPaths.felicitupsDashboard,
                            );
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
                  final notifications = state.notifications;

                  return Expanded(
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (_, index) {
                        return ListTile(
                          title: Text(
                            notifications[index].title,
                            style: context.styles.smallText,
                          ),
                          subtitle: Text(
                            notifications[index].body,
                            style: context.styles.paragraph,
                          ),
                          trailing: Text(
                            'id: ${notifications[index].messageId}',
                            style: context.styles.smallText,
                          ),
                          onTap: () {
                            redirectHelper(
                              data: notifications[index].data.toJson(),
                            );
                          },
                          onLongPress: () {
                            showConfirmModal(
                              title: 'Deseas eliminar la notificación?',
                              onAccept: () async {
                                context.read<NotificationsBloc>().add(
                                      NotificationsEvent.deleteNotification(
                                        notifications[index].messageId,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
