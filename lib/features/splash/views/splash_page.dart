import 'package:felicitup_app/features/splash/views/mobile/splash_mobile_page.dart';
import 'package:felicitup_app/features/splash/views/web/splash_web_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth > 1024) {
          return const SplashWebPage();
        }

        return const SplashMobilePage();
      },
    );
  }
}
