import 'dart:async';

import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/invite/bloc/invite_bloc.dart';
import 'package:felicitup_app/features/invite/views/mobile/invite_mobile_view.dart';
import 'package:felicitup_app/features/invite/views/web/invite_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:felicitup_app/injection/injection_container.dart' as injection;

class InvitePage extends StatelessWidget {
  final String felicitupId;

  const InvitePage({super.key, required this.felicitupId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => injection.di<InviteBloc>()
        ..add(InviteEvent.loadInviteData(felicitupId)),
      child: BlocListener<InviteBloc, InviteState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) async {
          if (state.isLoading) {
            unawaited(startLoadingModal());
          } else {
            await stopLoadingModal();
          }

          if (state.status == InviteStatus.authRequired) {
            context.push('${RouterPaths.login}?redirect=/invite/$felicitupId');
          } else if (state.status == InviteStatus.success) {
            context.go(RouterPaths.peopleFelicitup, extra: {'felicitupId': felicitupId});
          } else if (state.status == InviteStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Ocurrió un error')),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1024) {
              return const InviteWebView();
            }

            return const InviteMobileView();
          },
        ),
      ),
    );
  }
}
