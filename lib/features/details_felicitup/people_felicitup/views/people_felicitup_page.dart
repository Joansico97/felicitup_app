import 'package:felicitup_app/features/details_felicitup/people_felicitup/views/mobile/people_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/details_felicitup/people_felicitup/views/web/people_felicitup_web_page.dart';
import 'package:flutter/material.dart';

class PeopleFelicitupPage extends StatelessWidget {
  const PeopleFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const PeopleFelicitupWebPage();
        }

        return const PeopleFelicitupMobilePage();
      },
    );
  }
}
