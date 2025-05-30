import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/features.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:felicitup_app/injection/injection_container.dart' as injection;

part 'router_paths.dart';
part 'router_handler.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> detailsFelicitupNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> detailsPastFelicitupNavigatorKey =
    GlobalKey<NavigatorState>();

class CustomRouter {
  static final _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouterPaths.felicitupsDashboard,
    redirect: (context, state) {
      if (!RouterPaths().noAuthenticated.contains(state.matchedLocation)) {
        if (FirebaseAuth.instance.currentUser == null) {
          return RouterPaths.init;
        } else {
          return null;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouterPaths.init,
        pageBuilder: _initHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.login,
        pageBuilder: _loginHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.register,
        pageBuilder: _registerHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.federatedRegister,
        pageBuilder: _federatedRegisterHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.forgotPassword,
        pageBuilder: _forgotPasswordHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      ShellRoute(
        navigatorKey: homeNavigatorKey,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: _homeHandler,
        routes: [
          GoRoute(
            path: RouterPaths.createFelicitup,
            builder: _createFelicitupHandler,
            parentNavigatorKey: homeNavigatorKey,
          ),
          GoRoute(
            path: RouterPaths.felicitupsDashboard,
            builder: _felicitupsDashboardHandler,
            parentNavigatorKey: homeNavigatorKey,
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: detailsFelicitupNavigatorKey,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: _detailsFelicitupDashboardHandler,
        routes: [
          GoRoute(
            path: RouterPaths.infoFelicitup,
            builder: _infoFelicitupHandler,
            parentNavigatorKey: detailsFelicitupNavigatorKey,
          ),
          GoRoute(
            path: RouterPaths.messageFelicitup,
            builder: _messageFelicitupHandler,
            parentNavigatorKey: detailsFelicitupNavigatorKey,
          ),
          GoRoute(
            path: RouterPaths.peopleFelicitup,
            builder: _peopleFelicitupHandler,
            parentNavigatorKey: detailsFelicitupNavigatorKey,
          ),
          GoRoute(
            path: RouterPaths.videoFelicitup,
            builder: _videoFelicitupHandler,
            parentNavigatorKey: detailsFelicitupNavigatorKey,
          ),
          GoRoute(
            path: RouterPaths.boteFelicitup,
            builder: _boteFelicitupHandler,
            parentNavigatorKey: detailsFelicitupNavigatorKey,
          ),
        ],
      ),
      GoRoute(
        path: RouterPaths.payment,
        pageBuilder: _paymentHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.videoEditor,
        pageBuilder: _videoEditorHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.notifications,
        pageBuilder: _notificationsHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.profile,
        pageBuilder: _profileHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.wishList,
        pageBuilder: _wishListHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.wishListEdit,
        pageBuilder: _wishListEditHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.singleChat,
        pageBuilder: _singleChatHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.listSingleChat,
        pageBuilder: _listSingleChatHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.contacts,
        pageBuilder: _contactsHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.notificationsSettings,
        pageBuilder: _notificationsSettingsHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.termsPolicies,
        pageBuilder: _termsPoliciesHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.felicitupNotification,
        pageBuilder: _felicitupNotificationHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      ShellRoute(
        navigatorKey: detailsPastFelicitupNavigatorKey,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: _detailsPastFelicitupDashboardHandler,
        routes: [
          GoRoute(
            path: RouterPaths.mainPastFelicitup,
            builder: _mainPastFelicitupHandler,
            parentNavigatorKey: detailsPastFelicitupNavigatorKey,
          ),
          GoRoute(
            path: RouterPaths.chatPastFelicitup,
            builder: _chatPastFelicitupHandler,
            parentNavigatorKey: detailsPastFelicitupNavigatorKey,
          ),
          GoRoute(
            path: RouterPaths.peoplePastFelicitup,
            builder: _peoplePastFelicitupHandler,
            parentNavigatorKey: detailsPastFelicitupNavigatorKey,
          ),
          GoRoute(
            path: RouterPaths.videoPastFelicitup,
            builder: _videoPastFelicitupHandler,
            parentNavigatorKey: detailsPastFelicitupNavigatorKey,
          ),
        ],
      ),
      GoRoute(
        path: RouterPaths.reminders,
        pageBuilder: _remindersHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.phoneVerifyInt,
        pageBuilder: _phoneVerifyIntHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.updatePage,
        pageBuilder: _updateHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
      GoRoute(
        path: RouterPaths.deleteAccount,
        pageBuilder: _deleteAccountHandler,
        parentNavigatorKey: rootNavigatorKey,
      ),
    ],
  );

  GoRouter get router => _router;
}
