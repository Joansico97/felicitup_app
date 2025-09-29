import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.childView});

  final Widget childView;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _privacyPolicyUrl =
      'https://felicitup.com/politica-privacidad/#contactos-agenda';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppBloc>().state;
      if (appState.currentUser != null) {
        _checkAndRequestContactPermissions(appState);
      }
    });
  }

  void _checkAndRequestContactPermissions(AppState state) {
    final currentUser = state.currentUser;
    if (currentUser == null) return;

    final permissionStatus = state.contactsPermissionStatus;
    final isoCode = currentUser.isoCode ?? '';

    if (_hasContactsPermission(permissionStatus)) {
      _requestContactsUpdate(isoCode);
    } else if (Platform.isIOS && _shouldShowPermissionModal(currentUser)) {
      requestContactsPermissionWithModal();
    } else {
      _requestContactsUpdate(isoCode);
    }
  }

  /// Checks if the user has contacts permission (granted or limited)
  bool _hasContactsPermission(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }

  /// Determines if permission modal should be shown for iOS users
  bool _shouldShowPermissionModal(UserModel? user) {
    return user != null && (user.friendsPhoneList?.isEmpty ?? true);
  }

  /// Requests contacts update from HomeBloc
  void _requestContactsUpdate(String isoCode) {
    context.read<HomeBloc>().add(HomeEvent.getAndUpdateContacts(isoCode));
  }

  Future<void> requestContactsPermissionWithModal() async {
    try {
      final result = await showDialog<bool>(
        context: rootNavigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (_) => _buildContactsPermissionDialog(),
      );

      if (result == true) {
        context.read<AppBloc>().add(
          const AppEvent.requestManualContactsPermissions(),
        );
      }
    } catch (e) {
      logger.error('Error showing contacts permission modal: $e');
    }
  }

  /// Builds the contacts permission dialog
  Widget _buildContactsPermissionDialog() {
    return AlertDialog(
      title: Text(
        context.locale.contacts_modal_title,
        style: context.styles.header2,
      ),
      content: RichText(
        text: TextSpan(
          text: context.locale.contacts_modal_content,
          style: context.styles.paragraph,
          children: [
            TextSpan(
              text: context.locale.contacts_modal_security_info,
              style: context.styles.paragraph.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: context.locale.contacts_modal_process_info,
              style: context.styles.paragraph,
            ),
            TextSpan(
              text: context.locale.contacts_modal_policy_info,
              style: context.styles.paragraph.copyWith(
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _openPrivacyPolicy(),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => rootNavigatorKey.currentContext!.pop(false),
          child: Text('Cancelar', style: context.styles.buttons),
        ),
        TextButton(
          onPressed: () => rootNavigatorKey.currentContext!.pop(true),
          child: Text('Aceptar', style: context.styles.buttons),
        ),
      ],
    );
  }

  /// Opens the privacy policy URL
  Future<void> _openPrivacyPolicy() async {
    try {
      final url = Uri.parse(_privacyPolicyUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.inAppBrowserView,
          browserConfiguration: const BrowserConfiguration(showTitle: true),
        );
      } else {
        _showUrlErrorSnackBar();
      }
    } catch (e) {
      logger.error('Error opening privacy policy URL: $e');
      _showUrlErrorSnackBar();
    }
  }

  /// Shows error snackbar when URL cannot be opened
  void _showUrlErrorSnackBar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir la página. Verifica tu conexión a internet.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // BlocListener condition methods
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

    // User just logged in
    if (prevUser == null && currUser != null) return true;

    // User data changed (friends list or birth date)
    if (prevUser != null && currUser != null) {
      return prevUser.friendsPhoneList != currUser.friendsPhoneList ||
          prevUser.birthDate != currUser.birthDate;
    }

    return false;
  }

  // BlocListener handler methods
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

  /// Shows the birthday modal to collect user's birth date
  void _showBirthdayModal() {
    showConfirmModal(
      title: context.locale.birthday_modal_title,
      content: context.locale.birthday_modal_content,
      label: context.locale.birthday_modal_label,
      onAccept: () => _showBirthdayDatePicker(),
    );
  }

  /// Shows the birthday date picker dialog
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
