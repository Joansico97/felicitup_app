import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/single_chat/views/mobile/single_chat_mobile_page.dart';
import 'package:felicitup_app/features/single_chat/views/web/single_chat_web_page.dart';
import 'package:flutter/material.dart';

class SingleChatPage extends StatelessWidget {
  const SingleChatPage({super.key, required this.data});

  final SingleChatModel data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return SingleChatWebPage(data: data);
        }

        return SingleChatMobilePage(data: data);
      },
    );
  }
}
