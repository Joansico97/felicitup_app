import 'package:felicitup_app/app/app_observer.dart';
import 'package:felicitup_app/core/config/firebase_options.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> initConfig() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  usePathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializar Facebook SDK
  final facebookAnalytics = FacebookAnalyticsHelper();
  await facebookAnalytics.initialize();

  // Logear activación de la app
  await facebookAnalytics.logActivateApp();
}

Future<void> initObservers() async {
  Bloc.observer = AppObserver();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> initStorage() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
}
