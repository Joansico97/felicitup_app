import 'package:felicitup_app/features/phone_verify_int/views/mobile/phone_verify_int_mobile_page.dart';
import 'package:flutter/material.dart';

class PhoneVerifyIntWebPage extends StatelessWidget {
  const PhoneVerifyIntWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 600,
        child: PhoneVerifyIntMobilePage(),
      ),
    );
  }
}
