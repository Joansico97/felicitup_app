import 'package:felicitup_app/features/frequent_questions/views/mobile/frequent_questions_mobile_page.dart';
import 'package:flutter/material.dart';

class FrequentQuestionsWebPage extends StatelessWidget {
  const FrequentQuestionsWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 600,
        child: FrequentQuestionsMobilePage(),
      ),
    );
  }
}
