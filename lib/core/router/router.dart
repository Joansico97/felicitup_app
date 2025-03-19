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
final GlobalKey<NavigatorState> detailsFelicitupNavigatorKey = GlobalKey<NavigatorState>();

final noAuthenticated = [
  RouterPaths.init,
  RouterPaths.login,
  RouterPaths.register,
  RouterPaths.termsConditions,
  RouterPaths.verification,
  RouterPaths.inviteContacts,
  RouterPaths.resetPassword,
  RouterPaths.notificationInfo,
];

class CustomRouter {
  static final _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouterPaths.felicitupsDashboard,
    redirect: (context, state) {
      if (!noAuthenticated.contains(state.matchedLocation)) {
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
    ],
  );

  GoRouter get router => _router;
}
