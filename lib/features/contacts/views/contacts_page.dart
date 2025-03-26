import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/contacts/bloc/contacts_bloc.dart';
import 'package:felicitup_app/features/contacts/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AppBloc>().state.currentUser;
    if (currentUser != null) {
      context.read<ContactsBloc>().add(ContactsEvent.generateListData(
            currentUser.friendList ?? [],
            currentUser.friendsPhoneList ?? [],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactsBloc, ContactsState>(
      listenWhen: (previous, current) => previous.isLoading != current.isLoading,
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
                title: 'Contactos',
                onPressed: () async => context.go(RouterPaths.felicitupsDashboard),
              ),
              SizedBox(height: context.sp(12)),
              Expanded(
                child: BlocBuilder<ContactsBloc, ContactsState>(
                  buildWhen: (previous, current) => previous.dataList != current.dataList,
                  builder: (_, state) {
                    final listData = state.dataList;

                    return ListView.builder(
                      itemCount: listData?.length ?? 0,
                      itemBuilder: (_, index) => ElementCardRow(
                        contact: listData?[index]['contact'] as ContactModel,
                        isRegistered: listData?[index]['isRegistered'] as bool,
                        giftcars: index <= (state.listDataUsers?.length ?? 0)
                            ? (state.listDataUsers?[index].giftcardList)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
