import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/terms_policies/bloc/terms_policies_bloc.dart';
import 'package:felicitup_app/features/terms_policies/views/mobile/terms_policies_mobile_page.dart';
import 'package:felicitup_app/features/terms_policies/views/web/terms_policies_web_page.dart';
import 'package:felicitup_app/features/terms_policies/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TermsPoliciesPage extends StatelessWidget {
  const TermsPoliciesPage({
    super.key,
    required this.isTerms,
    required this.isFromFederated,
  });

  final bool isTerms;
  final bool isFromFederated;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TermsPoliciesBloc, TermsPoliciesState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return TermsPoliciesWebPage(
              isTerms: isTerms,
              isFromFederated: isFromFederated,
            );
          }

          return TermsPoliciesMobilePage(
            isTerms: isTerms,
            isFromFederated: isFromFederated,
          );
        },
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
        itemBuilder: (_, index) => ScrollButton(
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
        itemBuilder: (_, index) => ScrollButton(
          title: listData[index].title,
          content: listData[index].body,
        ),
      ),
    );
  }
}
