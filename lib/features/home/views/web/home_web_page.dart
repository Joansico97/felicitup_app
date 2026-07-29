import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HomeWebPage extends StatelessWidget {
  const HomeWebPage({
    super.key,
    required this.childView,
  });

  final Widget childView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerApp(),
      backgroundColor: context.colors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: childView,
        ),
      ),
    );
  }
}
