import 'package:felicitup_app/features/update/views/mobile/update_mobile_page.dart';
import 'package:flutter/material.dart';

class UpdateWebPage extends StatelessWidget {
  const UpdateWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 600,
        child: UpdateMobilePage(),
      ),
    );
  }
}
