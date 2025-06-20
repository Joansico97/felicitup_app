import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/terms_policies/widgets/widgets.dart';
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
            Expanded(child: isTerms ? TermsWidget() : PoliciesWidget()),
          ],
        ),
      ),
    );
  }
}

class PoliciesWidget extends StatelessWidget {
  const PoliciesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final listData = esPrivacyList;
    return FadeInRight(
      child: ListView.builder(
        itemCount: listData.length,
        itemBuilder:
            (_, index) => ScrollButton(
              title: listData[index]['title']!,
              content: listData[index]['content']!,
            ),
      ),
    );
  }
}

class TermsWidget extends StatelessWidget {
  const TermsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final listData = esTerms;

    return FadeInRight(
      child: ListView.builder(
        itemCount: listData.length,
        itemBuilder:
            (_, index) => ScrollButton(
              title: listData[index]['title']!,
              content: listData[index]['content']!,
            ),
      ),
    );
  }
}
