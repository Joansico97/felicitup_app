import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/data/resources/resources.dart';
import 'package:felicitup_app/features/features.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

part 'blocs_injection.dart';
part 'network_injection.dart';
part 'repositories_injection.dart';

final di = GetIt.instance;

Future<void> initInjections() async {
  _initNetworkInjection();
  _initRepositoriesInjection();
  _initBlocsInjection();
}
