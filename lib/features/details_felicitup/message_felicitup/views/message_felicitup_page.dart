import 'package:felicitup_app/features/details_felicitup/message_felicitup/views/mobile/message_felicitup_mobile_page.dart';
import 'package:felicitup_app/features/details_felicitup/message_felicitup/views/web/message_felicitup_web_page.dart';
import 'package:flutter/material.dart';

class MessageFelicitupPage extends StatelessWidget {
  const MessageFelicitupPage({super.key, this.chatId});

  final String? chatId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return MessageFelicitupWebPage(chatId: chatId);
        }

        return MessageFelicitupMobilePage(chatId: chatId);
      },
    );
  }
}
