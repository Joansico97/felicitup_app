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
        firebaseAuth: di(),
        firebaseStorage: di(),
        firebaseFunctionsHelper: di(),
        firestore: di(),
      ),
    )
    ..registerLazySingleton<FelicitupRepository>(
      () => FelicitupFirebaseResource(
        databaseHelper: di(),
        userRepository: di(),
        firebaseAuth: di(),
        firestore: di(),
        firebaseFunctionsHelper: di(),
      ),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatFirebaseResource(
        firestore: di(),
        firebaseAuth: di(),
        databaseHelper: di(),
      ),
    );
}
