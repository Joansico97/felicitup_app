import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/data/resources/resources.dart';
import 'package:felicitup_app/injection/injection_container.dart' as injection;
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/theme/theme.dart';
import 'package:felicitup_app/gen/l10n.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FelicitupApp extends StatelessWidget {
  const FelicitupApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = CustomRouter().router;
    final appBloc = injection.di<AppBloc>();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => injection.di<AuthRepository>(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => injection.di<UserRepository>(),
        ),
        RepositoryProvider<FelicitupRepository>(
          create: (_) => injection.di<FelicitupFirebaseResource>(),
        ),
        RepositoryProvider<ChatRepository>(
          create: (_) => injection.di<ChatFirebaseResource>(),
        ),
      ],
      child: BlocProvider<AppBloc>(
        create: (_) => appBloc,
        child: BlocBuilder<AppBloc, AppState>(
          builder: (_, state) {
            return MaterialApp.router(
              title: AppConstants.appTitle,
              localizationsDelegates: const [
                IntlTrans.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: IntlTrans.delegate.supportedLocales,
              theme: AppTheme().getTheme(),
              routerConfig: router,
              builder: (context, child) => HandleNotificationsInteractions(child: child!),
            );
          },
        ),
      ),
    );
  }
}

class HandleNotificationsInteractions extends StatefulWidget {
  const HandleNotificationsInteractions({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<HandleNotificationsInteractions> createState() => _HandleNotificationsInteractionsState();
}

class _HandleNotificationsInteractionsState extends State<HandleNotificationsInteractions> {
  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    final String type = message.data['type'];
    final pushMessageType = pushMessageTypeToEnum(type);
    final felicitupId = message.data['felicitupId'] ?? '';
    final chatId = message.data['chatId'] ?? '';
    final name = message.data['name'] ?? '';
    final ids = message.data['ids'] ?? [];

    switch (pushMessageType) {
      case PushMessageType.felicitup:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomRouter().router.go(
            RouterPaths.messageFelicitup,
            extra: {
              'felicitupId': felicitupId,
              'fromNotification': false,
            },
          );
        });
        break;
      case PushMessageType.chat:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomRouter().router.go(
            RouterPaths.messageFelicitup,
            extra: {
              'felicitupId': felicitupId,
              'fromNotification': false,
            },
          );
        });
      case PushMessageType.payment:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomRouter().router.go(
            RouterPaths.boteFelicitup,
            extra: {
              'felicitupId': felicitupId,
              'fromNotification': true,
            },
          );
        });
      case PushMessageType.singleChat:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomRouter().router.go(
            RouterPaths.singleChat,
            extra: {
              'chatId': chatId,
              'name': name,
              'ids': ids,
            },
          );
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
