import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/contacts/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ContactsWebPage extends StatelessWidget {
  const ContactsWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(20),
            vertical: context.sp(40),
          ),
          child: SizedBox(
            width: context.sp(600),
            child: Container(
              padding: EdgeInsets.all(context.sp(24)),
              decoration: BoxDecoration(
                color: context.colors.backgroundModal,
                borderRadius: BorderRadius.circular(context.sp(24)),
                border: Border.all(color: context.colors.lightGrey),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CollapsedHeader(
                    title: context.locale.contacts_title,
                    onPressed: () async =>
                        context.go(RouterPaths.felicitupsDashboard),
                  ),
                  SizedBox(height: context.sp(20)),
                  BlocBuilder<AppBloc, AppState>(
                    buildWhen: (previous, current) =>
                        previous.dataList != current.dataList ||
                        previous.isLoadingContacts != current.isLoadingContacts,
                    builder: (_, state) {
                      final listData = state.dataList;

                      if (state.isLoadingContacts) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listData?.length ?? 0,
                        itemBuilder: (_, index) => ElementCardRow(
                          contact: listData?[index]['contact'] as ContactModel,
                          isRegistered:
                              listData?[index]['isRegistered'] as bool,
                          giftcars: null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
