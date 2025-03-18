part of './injection_container.dart';

void _initNetworkInjection() {
  di
    ..registerLazySingleton<DatabaseHelper>(
      () => DatabaseHelper(
        firestore: di(),
      ),
    )
    ..registerLazySingleton<FirebaseAuth>(
      () => FirebaseAuth.instance,
    )
    ..registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    )
    ..registerLazySingleton<FirebaseMessaging>(
      () => FirebaseMessaging.instance,
    )
    ..registerLazySingleton<FirebaseFunctions>(
      () => FirebaseFunctions.instance,
    )
    ..registerLazySingleton<FirebaseStorage>(
      () => FirebaseStorage.instance,
    );
}
