import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/terms_policies/bloc/terms_policies_bloc.dart';
import 'package:felicitup_app/features/terms_policies/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TermsPoliciesPage extends StatefulWidget {
  const TermsPoliciesPage({
    super.key,
    required this.isTerms,
    required this.isFromFederated,
  });

  final bool isTerms;
  final bool isFromFederated;

  @override
  State<TermsPoliciesPage> createState() => _TermsPoliciesPageState();
}

class _TermsPoliciesPageState extends State<TermsPoliciesPage> {
  @override
  void initState() {
    context.read<TermsPoliciesBloc>().add(
      const TermsPoliciesEvent.getGeneralData(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TermsPoliciesBloc, TermsPoliciesState>(
      listenWhen:
          (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CollapsedHeader(
                title:
                    widget.isTerms
                        ? 'Términos y condiciones de uso'
                        : 'Política de privacidad',
                onPressed:
                    () =>
                        widget.isFromFederated
                            ? context.go(RouterPaths.federatedRegister)
                            : context.go(RouterPaths.register),
              ),
              SizedBox(height: context.sp(12)),
              BlocBuilder<TermsPoliciesBloc, TermsPoliciesState>(
                builder: (_, state) {
                  return Expanded(
                    child:
                        widget.isTerms
                            ? TermsWidget(
                              listData: state.termsAndConditions ?? [],
                            )
                            : PoliciesWidget(
                              listData: state.privacyPolicy ?? [],
                            ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PoliciesWidget extends StatelessWidget {
  const PoliciesWidget({super.key, required this.listData});

  final List<TermsPoliciesModel> listData;

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: ListView.builder(
        itemCount: listData.length,
        itemBuilder:
            (_, index) => ScrollButton(
              title: listData[index].title,
              content: listData[index].body,
            ),
      ),
    );
  }
}

class TermsWidget extends StatelessWidget {
  const TermsWidget({super.key, required this.listData});
  final List<TermsPoliciesModel> listData;

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: ListView.builder(
        itemCount: listData.length,
        itemBuilder:
            (_, index) => ScrollButton(
              title: listData[index].title,
              content: listData[index].body,
            ),
      ),
    );
  }
}
