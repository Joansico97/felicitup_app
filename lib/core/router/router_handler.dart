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

Page<Widget> _forgotPasswordHandler(BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => injection.di<ForgotPasswordBloc>(),
      child: const ForgotPasswordPage(),
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
Page<Widget> _federatedRegisterHandler(BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => injection.di<FederatedRegisterBloc>(),
      child: const FederatedRegisterPage(),
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

Page<Widget> _felicitupNotificationHandler(
  BuildContext context,
  GoRouterState state,
) {
  final data = state.extra as String;

  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<FelicitupNotificationBloc>()..add(FelicitupNotificationEvent.getFelicitupData(data)),
      child: FelicitupNotificationPage(),
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

Page<Widget> _detailsFelicitupDashboardHandler(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final data = state.extra as Map<String, dynamic>?;

  return CustomTransitionPage(
    key: state.pageKey,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => injection.di<DetailsFelicitupDashboardBloc>()
            ..add(
              data?['felicitupId'] == null
                  ? DetailsFelicitupDashboardEvent.noEvent()
                  : DetailsFelicitupDashboardEvent.startListening(data!['felicitupId'] as String),
            ),
        ),
        BlocProvider(create: (_) => injection.di<InfoFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<MessageFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<PeopleFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<VideoFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<BoteFelicitupBloc>()),
      ],
      child: DetailsFelicitupDashboardPage(
        key: ValueKey('DetailsFelicitupDashboardPage${data?['chatId']}'),
        childView: child,
        fromNotification: data?['fromNotification'] ?? false,
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
  final data = state.extra as Map<String, dynamic>;
  return MessageFelicitupPage(
    key: ValueKey('MessageFelicitupPage_${data['chatId']}'),
    chatId: data['chatId'] ?? '',
  );
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

Page<Widget> _paymentHandler(BuildContext context, GoRouterState state) {
  final data = state.extra as Map<String, dynamic>;

  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<PaymentBloc>(),
      child: PaymentPage(
        isVerify: data['isVerify'],
        felicitup: data['felicitup'],
        userId: data['userId'] ?? '',
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

Page<Widget> _videoEditorHandler(BuildContext context, GoRouterState state) {
  final data = state.extra as FelicitupModel;
  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<VideoEditorBloc>(),
      child: VideoEditorPage(
        felicitup: data,
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

Page<Widget> _notificationsHandler(BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<NotificationsBloc>(),
      child: NotificationsPage(),
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

Page<Widget> _profileHandler(BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<ProfileBloc>(),
      child: ProfilePage(),
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

Page<Widget> _wishListHandler(BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<WishListBloc>()..add(WishListEvent.startListening()),
      child: WishListPage(),
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

Page<Widget> _wishListEditHandler(BuildContext context, GoRouterState state) {
  final data = state.extra as GiftcarModel;

  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<WishListBloc>()..add(WishListEvent.startListening()),
      child: WishListEditPage(
        wishListItem: data,
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

Page<Widget> _singleChatHandler(BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<SingleChatBloc>(),
      child: SingleChatPage(),
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

Page<Widget> _listSingleChatHandler(BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<ListSingleChatBloc>(),
      child: ListSingleChatPage(),
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

Page<Widget> _contactsHandler(BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<ContactsBloc>(),
      child: ContactsPage(),
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

Page<Widget> _notificationsSettingsHandler(BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    child: BlocProvider(
      create: (_) => injection.di<NotificationsSettingsBloc>(),
      child: NotificationsSettingsPage(),
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

Page<Widget> _detailsPastFelicitupDashboardHandler(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final data = state.extra as Map<String, dynamic>?;

  return CustomTransitionPage(
    key: state.pageKey,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => injection.di<DetailsPastFelicitupDashboardBloc>()
            ..add(
              data?['felicitupId'] == null
                  ? DetailsPastFelicitupDashboardEvent.noEvent()
                  : DetailsPastFelicitupDashboardEvent.getFelicitupInfo(data!['felicitupId'] as String),
            ),
        ),
        BlocProvider(create: (_) => injection.di<MainPastFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<ChatPastFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<PeoplePastFelicitupBloc>()),
        BlocProvider(create: (_) => injection.di<VideoPastFelicitupBloc>()),
      ],
      child: DetailsPastFelicitupDashboardPage(
        childView: child,
        fromNotification: data?['fromNotification'] ?? false,
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

Widget _mainPastFelicitupHandler(BuildContext context, GoRouterState state) {
  return MainPastFelicitupPage();
}

Widget _chatPastFelicitupHandler(BuildContext context, GoRouterState state) {
  return ChatPastFelicitupPage();
}

Widget _peoplePastFelicitupHandler(BuildContext context, GoRouterState state) {
  return PeoplePastFelicitupPage();
}

Widget _videoPastFelicitupHandler(BuildContext context, GoRouterState state) {
  return VideoPastFelicitupPage();
}
