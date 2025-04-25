import 'package:bloc/bloc.dart';
import 'package:felicitup_app/app/app_observer.dart';
import 'package:felicitup_app/core/config/firebase_options.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> initConfig() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> initObservers() async {
  /// Initialize the [BlocObserver]. This will allow us to observe all Blocs and their changes.
  /// This is useful for debugging and logging purposes.
  Bloc.observer = AppObserver();

  /// Initialize the [FirebaseCrashlytics] observer. This will allow us to log errors and crashes to Firebase.
  /// This is useful for monitoring the app's stability and performance.
  FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> initStorage() async {
  final localStorage = LocalStorageHelper();
  await localStorage.init();
}
