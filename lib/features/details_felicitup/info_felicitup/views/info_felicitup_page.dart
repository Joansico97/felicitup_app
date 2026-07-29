import 'package:felicitup_app/features/details_felicitup/info_felicitup/views/mobile/info_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/details_felicitup/info_felicitup/views/web/info_felicitup_web_page.dart';
import 'package:flutter/material.dart';

class InfoFelicitupPage extends StatelessWidget {
  const InfoFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const InfoFelicitupWebPage();
        }

        return const InfoFelicitupMobilePage();
      },
    );
  }
}
