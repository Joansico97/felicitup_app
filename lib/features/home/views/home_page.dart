import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppBloc>().state;
      if (appState.currentUser != null) {}
    });
  }

  bool _shouldHandleNotificationPayload(AppState previous, AppState current) {
    return previous.pendingNotificationPayload !=
        current.pendingNotificationPayload;
  }

  bool _shouldUpdateMatchList(AppState previous, AppState current) {
    return previous.currentUser?.friendsPhoneList !=
        current.currentUser?.friendsPhoneList;
  }

  bool _shouldHandleUserDataChanges(AppState previous, AppState current) {
    final prevUser = previous.currentUser;
    final currUser = current.currentUser;

    if (prevUser == null && currUser != null) return true;

    if (prevUser != null && currUser != null) {
      return prevUser.friendsPhoneList != currUser.friendsPhoneList ||
          prevUser.birthDate != currUser.birthDate;
    }

    return false;
  }

  void _handleNotificationPayload(BuildContext context, AppState state) {
    if (state.pendingNotificationPayload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          redirectHelper(data: state.pendingNotificationPayload!);
          context.read<AppBloc>().add(
            const AppEvent.clearPendingNotification(),
          );
        }
      });
    }
  }

  void _handleMatchListUpdate(BuildContext context, AppState state) {
    context.read<AppBloc>().add(const AppEvent.updateMatchListFromContacts());
  }

  void _handleUserDataChanges(BuildContext context, AppState state) {
    final currentUser = state.currentUser;
    if (currentUser == null) return;

    if (currentUser.birthDate == null) {
      _showBirthdayModal();
    } else if (currentUser.phone?.isEmpty ?? true) {
      context.go(RouterPaths.phoneVerifyInt);
    }
  }

  void _showBirthdayModal() {
    showConfirmModal(
      title: context.locale.birthday_modal_title,
      content: context.locale.birthday_modal_content,
      label: context.locale.birthday_modal_label,
      onAccept: () => _showBirthdayDatePicker(),
    );
  }

  Future<void> _showBirthdayDatePicker() async {
    try {
      DateTime? birthDate;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            context.locale.birthday_modal_question_title,
            style: context.styles.header2,
          ),
          content: DatePickerWidget(
            onSelectNewDate: (date) => birthDate = date,
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<HomeBloc>().add(
                  HomeEvent.setUserBirthdate(date: birthDate ?? DateTime.now()),
                );
                context.pop();
              },
              child: Text('Aceptar', style: context.styles.buttons),
            ),
          ],
        ),
      );
    } catch (e) {
      logger.error('Error showing birthday date picker: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppBloc, AppState>(
          listenWhen: _shouldHandleNotificationPayload,
          listener: _handleNotificationPayload,
        ),

        BlocListener<AppBloc, AppState>(
          listenWhen: _shouldUpdateMatchList,
          listener: _handleMatchListUpdate,
        ),

        BlocListener<AppBloc, AppState>(
          listenWhen: _shouldHandleUserDataChanges,
          listener: _handleUserDataChanges,
        ),
      ],
      child: Scaffold(
        drawer: const DrawerApp(),
        backgroundColor: context.colors.background,
        body: widget.childView,
      ),
    );
  }
}
