import 'package:felicitup_app/features/details_felicitup/info_felicitup/views/mobile/info_felicitup_mobile_page.dart';
import 'package:flutter/material.dart';

class InfoFelicitupWebPage extends StatelessWidget {
  const InfoFelicitupWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const InfoFelicitupMobilePage(),
      ),
    );
  }
}
