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
      // GoRoute(
      //   path: RouterPaths.home,
      //   pageBuilder: _homeHandler,
      //   parentNavigatorKey: rootNavigatorKey,
      // ),
      // GoRoute(
      //   path: RouterPaths.federatedRegister,
      //   name: RouterPaths.federatedRegister,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _federatedRegisterHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.finishRegister,
      //   name: RouterPaths.finishRegister,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _finishRegisterHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.termsConditions,
      //   name: RouterPaths.termsConditions,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _termsConditionsHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.verification,
      //   name: RouterPaths.verification,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _verificationHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.notifications,
      //   name: RouterPaths.notifications,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _notificationHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.inviteContacts,
      //   name: RouterPaths.inviteContacts,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _inviteContactsHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.felicitupDetails,
      //   name: RouterPaths.felicitupDetails,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _felicitupDetailsHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.pastFelicitups,
      //   name: RouterPaths.pastFelicitups,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _pastFelicitupHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.resetPassword,
      //   name: RouterPaths.resetPassword,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _resetPasswordHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.profile,
      //   name: RouterPaths.profile,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _profileHandler,
      // ),
      // GoRoute(
      //   path: '${RouterPaths.notificationInfo}/:felicitupId',
      //   name: RouterPaths.notificationInfo,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _notificationInfoHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.confirmPayment,
      //   name: RouterPaths.confirmPayment,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _confirmPaymentHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.verifyPayment,
      //   name: RouterPaths.verifyPayment,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _verifyPaymentHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.videoEditor,
      //   name: RouterPaths.videoEditor,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _videoEditorHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.contacts,
      //   name: RouterPaths.contacts,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _contactsHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.detailsContact,
      //   name: RouterPaths.detailsContact,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _detailsContactHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.notificationsSettings,
      //   name: RouterPaths.notificationsSettings,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _notificationsSettingsHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.giftcard,
      //   name: RouterPaths.giftcard,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _giftcardHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.giftcardItemDetail,
      //   name: RouterPaths.giftcardItemDetail,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _giftcardItemDetailHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.singleChat,
      //   name: RouterPaths.singleChat,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _singleChatHandler,
      // ),
      // GoRoute(
      //   path: RouterPaths.listSingleChat,
      //   name: RouterPaths.listSingleChat,
      //   parentNavigatorKey: rootNavigatorKey,
      //   builder: _listSingleChatHandler,
      // ),
    ],
  );

  GoRouter get router => _router;
}
