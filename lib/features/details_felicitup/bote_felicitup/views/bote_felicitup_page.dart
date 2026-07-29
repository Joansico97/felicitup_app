import 'package:felicitup_app/features/details_felicitup/bote_felicitup/views/mobile/bote_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/details_felicitup/bote_felicitup/views/web/bote_felicitup_web_page.dart';
import 'package:flutter/material.dart';

class BoteFelicitupPage extends StatelessWidget {
  const BoteFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const BoteFelicitupWebPage();
        }

        return const BoteFelicitupMobilePage();
      },
    );
  }
}
