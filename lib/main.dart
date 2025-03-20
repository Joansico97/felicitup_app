import 'package:felicitup_app/app/app.dart';
import 'package:felicitup_app/core/config/config.dart';
import 'package:flutter/material.dart';
import 'package:felicitup_app/injection/injection_container.dart' as injection;

Future<void> main() async {
  await initConfig();
  await initObservers();
  await injection.initInjections();
  runApp(const FelicitupApp());
}
