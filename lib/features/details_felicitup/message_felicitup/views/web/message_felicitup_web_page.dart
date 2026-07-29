import 'package:felicitup_app/features/details_felicitup/message_felicitup/views/mobile/message_felicitup_mobile_page.dart';
import 'package:flutter/material.dart';

class MessageFelicitupWebPage extends StatelessWidget {
  const MessageFelicitupWebPage({super.key, this.chatId});

  final String? chatId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: MessageFelicitupMobilePage(chatId: chatId),
      ),
    );
  }
}
