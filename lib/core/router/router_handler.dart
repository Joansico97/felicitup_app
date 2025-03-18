part of 'router.dart';

Page<Widget> _initHandler(BuildContext context, GoRouterState state) => CustomTransitionPage(
      key: state.pageKey,
      child: const InitPage(),
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );

Page<Widget> _loginHandler(BuildContext context, GoRouterState state) => CustomTransitionPage(
      key: state.pageKey,
      child: BlocProvider(
        create: (_) => injection.di<LoginBloc>(),
        child: const LoginPage(),
      ),
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
Page<Widget> _registerHandler(BuildContext context, GoRouterState state) => CustomTransitionPage(
      key: state.pageKey,
      child: BlocProvider(
        create: (_) => injection.di<RegisterBloc>(),
        child: const RegisterPage(),
      ),
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );

Page<Widget> _homeHandler(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => injection.di<HomeBloc>()),
        BlocProvider(create: (_) => injection.di<CreateFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<FelicitupsDashboardBloc>()),
      ],
      child: HomePage(
        childView: child,
      ),
    ),
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

Widget _createFelicitupHandler(BuildContext context, GoRouterState state) {
  return CreateFelicitupPage();
}

Widget _felicitupsDashboardHandler(BuildContext context, GoRouterState state) {
  return FelicitupsDashboardPage();
}

Page<Widget> _detailsFelicitupDashboardHandler(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final data = state.extra as String?;

  return CustomTransitionPage(
    key: state.pageKey,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => injection.di<DetailsFelicitupDashboardBloc>()
            ..add(
              data == null
                  ? DetailsFelicitupDashboardEvent.noEvent()
                  : DetailsFelicitupDashboardEvent.getFelicitupInfo(data),
            ),
        ),
        BlocProvider(create: (_) => injection.di<InfoFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<MessageFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<PeopleFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<VideoFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<BoteFelicitupBloc>()),
      ],
      child: DetailsFelicitupDashboardPage(
        childView: child,
      ),
    ),
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

Widget _infoFelicitupHandler(BuildContext context, GoRouterState state) {
  return InfoFelicitupPage();
}

Widget _messageFelicitupHandler(BuildContext context, GoRouterState state) {
  return MessageFelicitupPage();
}

Widget _peopleFelicitupHandler(BuildContext context, GoRouterState state) {
  return PeopleFelicitupPage();
}

Widget _videoFelicitupHandler(BuildContext context, GoRouterState state) {
  return VideoFelicitupPage();
}

Widget _boteFelicitupHandler(BuildContext context, GoRouterState state) {
  return BoteFelicitupPage();
}

// Widget _loginHandler(BuildContext context, GoRouterState state) => const LoginPage();
// Widget _registerHandler(BuildContext context, GoRouterState state) => const RegisterPage();
// Widget _federatedRegisterHandler(BuildContext context, GoRouterState state) => const FedearatedRegisterPage();
// Widget _finishRegisterHandler(BuildContext context, GoRouterState state) => const FinishRegisterPage();
// Widget _termsConditionsHandler(BuildContext context, GoRouterState state) => const TermsConditionsPage();

// Widget _verificationHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return VerificationPage(
//     isRegister: data['isRegister'],
//     isFederated: data['isFederated'],
//   );
// }

// Widget _notificationHandler(BuildContext context, GoRouterState state) => const NotificationsPage();
// Widget _inviteContactsHandler(BuildContext context, GoRouterState state) => const InviteContactsPage();
// Widget _felicitupDetailsHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return Consumer(
//     builder: (_, ref, __) {
//       Future.delayed(Duration.zero, () async {
//         await ref.read(felicitupDetailsEventProvider.notifier).getFelicitup(id: data['felicitupId']);
//         if (data['change'] != null && data['change']) {
//           ref.read(felicitupDetailsEventProvider.notifier).changePageFromFelicitup(2);
//         }
//         if (data['change'] != null && !data['change']) {
//           ref.read(felicitupDetailsEventProvider.notifier).changePageFromFelicitup(4);
//         }
//         if (data['reset'] != null && data['reset']) {
//           ref.read(felicitupDetailsEventProvider.notifier).changePageFromFelicitup(1);
//         }
//       });
//       return FelicitupDetailsPage(
//         felicitupId: data['felicitupId'],
//       );
//     },
//   );
// }

// Widget _resetPasswordHandler(BuildContext context, GoRouterState state) => const ResetPasswordPage();

// Widget _profileHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return ProfilePage(
//     user: data['user'],
//   );
// }

// Widget _notificationInfoHandler(BuildContext context, GoRouterState state) {
//   final data = state.pathParameters['felicitupId'];
//   return NotificationInfoPage(
//     id: data ?? '',
//   );
// }

// Widget _confirmPaymentHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return ConfirmPaymentPage(
//     reason: data['reason'],
//     initDate: data['initDate'],
//     finalDate: data['finalDate'],
//     felicitup: data['felicitup'],
//   );
// }

// Widget _verifyPaymentHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return VerifyPaymentPage(
//     felicitup: data['felicitup'],
//     id: data['id'],
//   );
// }

// Widget _videoEditorHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return VideoEditorPage(
//     felicitupId: data['felicitupId'],
//   );
// }

// Widget _contactsHandler(BuildContext context, GoRouterState state) {
//   return const ContactsPage();
// }

// Widget _detailsContactHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return DetailsContactPage(
//     contact: data['contact'],
//   );
// }

// Widget _notificationsSettingsHandler(BuildContext context, GoRouterState state) {
//   return const NotificationsSettingsPage();
// }

// Widget _giftcardHandler(BuildContext context, GoRouterState state) {
//   return GiftcardPage();
// }

// Widget _giftcardItemDetailHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return GiftcardItemDetail(
//     giftcardItem: data['giftcardItem'],
//   );
// }

// Widget _listSingleChatHandler(BuildContext context, GoRouterState state) {
//   return ListSingleChatsPage();
// }

// Widget _singleChatHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return SingleChatPage(
//     chatId: data['chatId'],
//     name: data['name'],
//     ids: data['ids'],
//   );
// }

// Widget _pastFelicitupHandler(BuildContext context, GoRouterState state) {
//   final data = state.extra as Map<String, dynamic>;
//   return Consumer(builder: (_, ref, __) {
//     Future.delayed(Duration.zero, () async {
//       await ref.read(pastFelicitupEventsProvider.notifier).getFelicitup(id: data['felicitupId']);
//       ref.read(pastFelicitupEventsProvider.notifier).changePageFromFelicitup(1);
//     });
//     return PastFelicitupPage(
//       felicitupId: data['felicitupId'],
//     );
//   });
// }
