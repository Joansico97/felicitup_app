import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class MessageFelicitupPage extends StatelessWidget {
  const MessageFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Text('Message Felicitup Page'),
      ),
    );
  }
}
