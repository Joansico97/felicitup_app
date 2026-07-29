import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ListSingleChatWebPage extends StatelessWidget {
  const ListSingleChatWebPage({super.key});

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
            width: context.sp(500),
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
                    title: context.locale.chats_title,
                    onPressed: () async =>
                        context.go(RouterPaths.felicitupsDashboard),
                  ),
                  SizedBox(height: context.sp(20)),
                  BlocBuilder<AppBloc, AppState>(
                    builder: (_, state) {
                      final listChats = state.currentUser?.singleChats ?? [];

                      if (listChats.isEmpty) {
                        return Center(
                          child: Text(
                            context.locale.no_chats,
                            style: context.styles.paragraph,
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listChats.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: context.sp(12)),
                        itemBuilder: (_, index) {
                          return ListTile(
                            title: Text(
                              listChats[index].userName ?? '',
                              style: context.styles.subtitle,
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                listChats[index].userImage ?? '',
                              ),
                            ),
                            onTap: () => context.go(
                              RouterPaths.singleChat,
                              extra: listChats[index],
                            ),
                          );
                        },
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
