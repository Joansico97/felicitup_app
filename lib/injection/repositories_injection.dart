part of './injection_container.dart';

void _initRepositoriesInjection() {
  di
    ..registerLazySingleton<AuthRepository>(
      () => AuthFirebaseResource(
        client: di(),
        firebaseAuth: di(),
      ),
    )
    ..registerLazySingleton<UserRepository>(
      () => UserFirebaseResource(
        client: di(),
      ),
    )
    ..registerLazySingleton<FelicitupRepository>(
      () => FelicitupFirebaseResource(
        databaseHelper: di(),
        userRepository: di(),
        firebaseAuth: di(),
        firestore: di(),
      ),
    );
}
