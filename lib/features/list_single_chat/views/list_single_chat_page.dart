import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ListSingleChatPage extends StatelessWidget {
  const ListSingleChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CollapsedHeader(
              title: 'Mensajes directos',
              onPressed: () async => context.go(RouterPaths.felicitupsDashboard),
            ),
            SizedBox(height: context.sp(12)),
            Expanded(
              child: BlocBuilder<AppBloc, AppState>(
                builder: (_, state) {
                  final listChats = state.currentUser?.singleChats ?? [];

                  return ListView.separated(
                    itemCount: listChats.length,
                    separatorBuilder: (_, __) => SizedBox(height: context.sp(12)),
                    itemBuilder: (_, index) {
                      return SizedBox(
                        child: ListTile(
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
