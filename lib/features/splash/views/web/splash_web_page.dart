import 'package:felicitup_app/features/splash/views/mobile/splash_mobile_page.dart';
import 'package:flutter/material.dart';

class SplashWebPage extends StatelessWidget {
  const SplashWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 600,
        child: SplashMobilePage(),
      ),
    );
  }
}
