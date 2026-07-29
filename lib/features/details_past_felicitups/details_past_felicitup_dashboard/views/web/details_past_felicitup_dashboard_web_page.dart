import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitup_dashboard/views/mobile/details_past_felicitup_dashboard_mobile_page.dart';
import 'package:flutter/material.dart';

class DetailsPastFelicitupDashboardWebPage extends StatelessWidget {
  const DetailsPastFelicitupDashboardWebPage({
    super.key,
    required this.childView,
  });

  final Widget childView;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: DetailsPastFelicitupDashboardMobilePage(childView: childView),
      ),
    );
  }
}
