import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotificationsWebPage extends StatefulWidget {
  const NotificationsWebPage({super.key});

  @override
  State<NotificationsWebPage> createState() => _NotificationsWebPageState();
}

class _NotificationsWebPageState extends State<NotificationsWebPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(
          const NotificationsEvent.getNotifications(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(20),
            vertical: context.sp(40),
          ),
          child: SizedBox(
            width: context.sp(550),
            child: Container(
              padding: EdgeInsets.all(context.sp(24)),
              decoration: BoxDecoration(
                color: context.colors.backgroundModal,
                borderRadius: BorderRadius.circular(context.sp(24)),
                border: Border.all(color: context.colors.lightGrey),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CollapsedHeader(
                    title: context.locale.notifications_title,
                    onPressed: () async =>
                        context.go(RouterPaths.felicitupsDashboard),
                  ),
                  SizedBox(height: context.sp(20)),
                  BlocBuilder<NotificationsBloc, NotificationsState>(
                    builder: (_, state) {
                      final notifications = List.of(state.notifications)
                        ..sort(
                          (a, b) => (a.sentDate ?? DateTime(0)).compareTo(
                            b.sentDate ?? DateTime(0),
                          ),
                        );

                      if (notifications.isEmpty) {
                        return Center(
                          child: Text(
                            context.locale.no_notifications,
                            style: context.styles.paragraph,
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (_, index) {
                          final dateFormatted = DateFormat('dd/MM/yyyy HH:mm')
                              .format(notifications[index].sentDate ?? DateTime.now());
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
                                    context.locale.received_on(dateFormatted),
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
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
