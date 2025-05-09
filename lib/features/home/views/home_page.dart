import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.childView});

  final Widget childView;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AppBloc>().add(AppEvent.loadUserData());
    context.read<AppBloc>().add(AppEvent.initializeNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen:
          (previous, current) => previous.currentUser != current.currentUser,
      listener: (_, state) {
        if (state.currentUser?.phone == null ||
            (state.currentUser?.phone?.isEmpty ?? false)) {
          context.go(RouterPaths.phoneVerifyInt);
        }
        context.read<AppBloc>().add(
          AppEvent.updateMatchList(state.currentUser?.friendsPhoneList ?? []),
        );
        context.read<HomeBloc>().add(
          HomeEvent.getAndUpdateContacts(state.currentUser?.isoCode ?? ''),
        );
      },
      child: Scaffold(
        drawer: const DrawerApp(),
        backgroundColor: context.colors.background,
        body: widget.childView,
      ),
    );
  }
}
