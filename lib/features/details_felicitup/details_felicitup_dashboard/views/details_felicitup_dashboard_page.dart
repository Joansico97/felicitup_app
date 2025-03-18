import 'package:flutter/material.dart';

class DetailsFelicitupDashboardPage extends StatelessWidget {
  const DetailsFelicitupDashboardPage({
    super.key,
    required this.childView,
  });

  final Widget childView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Details Felicitup Dashboard Page'),
      ),
    );
  }
}
