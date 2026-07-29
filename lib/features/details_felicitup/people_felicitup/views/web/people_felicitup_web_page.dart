import 'package:felicitup_app/features/details_felicitup/people_felicitup/views/mobile/people_felicitup_mobile_page.dart';
import 'package:flutter/material.dart';

class PeopleFelicitupWebPage extends StatelessWidget {
  const PeopleFelicitupWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const PeopleFelicitupMobilePage(),
      ),
    );
  }
}
