import 'package:felicitup_app/features/update/views/mobile/update_mobile_page.dart';
import 'package:felicitup_app/features/update/views/web/update_web_page.dart';
import 'package:flutter/material.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth > 1024) {
          return const UpdateWebPage();
        }

        return const UpdateMobilePage();
      },
    );
  }
}
