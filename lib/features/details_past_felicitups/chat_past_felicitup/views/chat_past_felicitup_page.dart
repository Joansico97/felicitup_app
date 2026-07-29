import 'package:felicitup_app/features/details_past_felicitups/chat_past_felicitup/views/mobile/chat_past_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/details_past_felicitups/chat_past_felicitup/views/web/chat_past_felicitup_web_page.dart';
import 'package:flutter/material.dart';

class ChatPastFelicitupPage extends StatelessWidget {
  const ChatPastFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const ChatPastFelicitupWebPage();
        }

        return const ChatPastFelicitupMobilePage();
      },
    );
  }
}
