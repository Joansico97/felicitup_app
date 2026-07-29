import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/views/mobile/details_felicitup_dashboard_mobile_page.dart';
import 'package:flutter/material.dart';

class DetailsFelicitupDashboardWebPage extends StatelessWidget {
  const DetailsFelicitupDashboardWebPage({
    super.key,
    required this.childView,
    required this.fromNotification,
    this.chatId,
  });

  final Widget childView;
  final bool fromNotification;
  final String? chatId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: DetailsFelicitupDashboardMobilePage(
          childView: childView,
          fromNotification: fromNotification,
          chatId: chatId,
        ),
      ),
    );
  }
}
