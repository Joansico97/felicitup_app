import 'package:felicitup_app/features/frequent_questions/views/mobile/frequent_questions_mobile_page.dart';
import 'package:felicitup_app/features/frequent_questions/views/web/frequent_questions_web_page.dart';
import 'package:flutter/material.dart';

class FrequentQuestionsPage extends StatelessWidget {
  const FrequentQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return const FrequentQuestionsWebPage();
        }

        return const FrequentQuestionsMobilePage();
      },
    );
  }
}
