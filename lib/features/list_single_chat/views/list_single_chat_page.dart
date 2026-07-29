import 'package:felicitup_app/features/list_single_chat/views/mobile/list_single_chat_mobile_page.dart';
import 'package:felicitup_app/features/list_single_chat/views/web/list_single_chat_web_page.dart';
import 'package:flutter/material.dart';

class ListSingleChatPage extends StatelessWidget {
  const ListSingleChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const ListSingleChatWebPage();
        }

        return const ListSingleChatMobilePage();
      },
    );
  }
}
