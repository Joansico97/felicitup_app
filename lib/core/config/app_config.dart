import 'package:felicitup_app/app/app_observer.dart';
import 'package:felicitup_app/core/config/firebase_options.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initConfig() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializar Facebook SDK
  final facebookAnalytics = FacebookAnalyticsHelper();
  await facebookAnalytics.initialize();

  // Rastrear instalación si es la primera vez que se abre la app
  await facebookAnalytics.trackInstall();

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
  final localStorage = LocalStorageHelper();
  await localStorage.init();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );
}
