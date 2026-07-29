import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/contacts/bloc/contacts_bloc.dart';
import 'package:felicitup_app/features/contacts/views/mobile/contacts_mobile_page.dart';
import 'package:felicitup_app/features/contacts/views/web/contacts_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactsBloc, ContactsState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.reloadContacts != current.reloadContacts,
      listener: (context, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
        if (state.reloadContacts) {
          context.read<AppBloc>()
            ..add(const AppEvent.loadUserData())
            ..add(const AppEvent.loadContacts());
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return const ContactsWebPage();
          }

          return const ContactsMobilePage();
        },
      ),
    );
  }
}
