import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/profile/bloc/profile_bloc.dart';
import 'package:felicitup_app/features/profile/views/mobile/profile_mobile_page.dart';
import 'package:felicitup_app/features/profile/views/web/profile_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.status != current.status,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == ProfileStatus.success) {
          context.read<AppBloc>().add(const AppEvent.loadUserData());
          context.go(RouterPaths.felicitupsDashboard);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return const ProfileWebPage();
          }

          return const ProfileMobilePage();
        },
      ),
    );
  }
}
