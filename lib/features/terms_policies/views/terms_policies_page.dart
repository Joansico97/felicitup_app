import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsPoliciesPage extends StatelessWidget {
  const TermsPoliciesPage({super.key, required this.isTerms});

  final bool isTerms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CollapsedHeader(
              title:
                  isTerms
                      ? 'Términos y condiciones de uso'
                      : 'Política de privacidad',
              onPressed: () async => context.go(RouterPaths.register),
            ),
            SizedBox(height: context.sp(12)),
          ],
        ),
      ),
    );
  }
}
