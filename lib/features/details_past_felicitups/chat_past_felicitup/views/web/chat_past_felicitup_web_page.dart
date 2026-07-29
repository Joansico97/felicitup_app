import 'package:felicitup_app/features/details_past_felicitups/chat_past_felicitup/views/mobile/chat_past_felicitup_mobile_page.dart';
import 'package:flutter/material.dart';

class ChatPastFelicitupWebPage extends StatelessWidget {
  const ChatPastFelicitupWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const ChatPastFelicitupMobilePage(),
      ),
    );
  }
}
