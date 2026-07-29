import 'package:felicitup_app/features/details_felicitup/bote_felicitup/views/mobile/bote_felicitup_mobile_page.dart';
import 'package:flutter/material.dart';

class BoteFelicitupWebPage extends StatelessWidget {
  const BoteFelicitupWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const BoteFelicitupMobilePage(),
      ),
    );
  }
}
