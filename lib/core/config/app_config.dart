import 'package:bloc/bloc.dart';
import 'package:felicitup_app/app/app_observer.dart';
import 'package:felicitup_app/core/config/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> initConfig() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await Hive.initFlutter();
  // await _openBoxesLocalStorage();
}

Future<void> initObservers() async {
  /// Initialize the [BlocObserver]. This will allow us to observe all Blocs and their changes.
  /// This is useful for debugging and logging purposes.
  Bloc.observer = AppObserver();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

// Future<void> _openBoxesLocalStorage() async {
//   await Hive.openBox(LocalStorageConstants.sessionBox);
//   await Hive.openBox(LocalStorageConstants.chatBox);
// }
