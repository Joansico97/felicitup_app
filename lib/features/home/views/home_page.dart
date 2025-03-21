import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.childView,
  });

  final Widget childView;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AppBloc>().state.currentUser;
    context.read<AppBloc>().add(AppEvent.loadUserData());
    context.read<AppBloc>().add(AppEvent.initializeNotifications());
    logger.info(context.read<AppBloc>().state.status);
    if (currentUser != null) {
      context.read<HomeBloc>().add(HomeEvent.getAndUpdateContacts(currentUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (_, state) {},
      child: Scaffold(
        drawer: const DrawerApp(),
        backgroundColor: context.colors.background,
        body: widget.childView,
      ),
    );
  }
}
