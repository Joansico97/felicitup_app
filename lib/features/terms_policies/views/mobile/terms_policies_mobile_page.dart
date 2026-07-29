import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/terms_policies/bloc/terms_policies_bloc.dart';
import 'package:felicitup_app/features/terms_policies/views/terms_policies_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TermsPoliciesMobilePage extends StatefulWidget {
  const TermsPoliciesMobilePage({
    super.key,
    required this.isTerms,
    required this.isFromFederated,
  });

  final bool isTerms;
  final bool isFromFederated;

  @override
  State<TermsPoliciesMobilePage> createState() =>
      _TermsPoliciesMobilePageState();
}

class _TermsPoliciesMobilePageState extends State<TermsPoliciesMobilePage> {
  @override
  void initState() {
    context.read<TermsPoliciesBloc>().add(
          const TermsPoliciesEvent.getGeneralData(),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            CollapsedHeader(
              title: widget.isTerms
                  ? 'Términos y condiciones de uso'
                  : 'Política de privacidad',
              onPressed: () => widget.isFromFederated
                  ? context.go(RouterPaths.federatedRegister)
                  : context.go(RouterPaths.register),
            ),
            SizedBox(height: context.sp(12)),
            BlocBuilder<TermsPoliciesBloc, TermsPoliciesState>(
              builder: (_, state) {
                return Expanded(
                  child: widget.isTerms
                      ? TermsWidget(listData: state.termsAndConditions ?? [])
                      : PoliciesWidget(listData: state.privacyPolicy ?? []),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
