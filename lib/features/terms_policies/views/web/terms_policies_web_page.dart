import 'package:felicitup_app/features/terms_policies/views/mobile/terms_policies_mobile_page.dart';
import 'package:flutter/material.dart';

class TermsPoliciesWebPage extends StatelessWidget {
  const TermsPoliciesWebPage({
    super.key,
    required this.isTerms,
    required this.isFromFederated,
  });

  final bool isTerms;
  final bool isFromFederated;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: TermsPoliciesMobilePage(
          isTerms: isTerms,
          isFromFederated: isFromFederated,
        ),
      ),
    );
  }
}
