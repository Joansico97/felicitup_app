part of './injection_container.dart';

void _initBlocsInjection() {
  di
    ..registerLazySingleton(
      () => AppBloc(
        userRepository: di(),
        authRepository: di(),
        firebaseAuth: di(),
      ),
    )
    ..registerFactory(
      () => LoginBloc(
        authRepository: di(),
      ),
    )
    ..registerFactory(
      () => RegisterBloc(),
    )
    ..registerFactory(
      () => HomeBloc(),
    )
    ..registerFactory(
      () => CreateFelicitupBloc(
        databaseHelper: di(),
        userRepository: di(),
        felicitupRepository: di(),
      ),
    )
    ..registerFactory(
      () => FelicitupsDashboardBloc(
        felicitupRepository: di(),
        firebaseAuth: di(),
      ),
    )
    ..registerFactory(
      () => DetailsFelicitupDashboardBloc(
        felicitupRepository: di(),
        userRepository: di(),
      ),
    )
    ..registerFactory(
      () => InfoFelicitupBloc(),
    )
    ..registerFactory(
      () => MessageFelicitupBloc(
        felicitupRepository: di(),
        userRepository: di(),
        chatRepository: di(),
      ),
    )
    ..registerFactory(
      () => PeopleFelicitupBloc(
        felicitupRepository: di(),
        firebaseAuth: di(),
      ),
    )
    ..registerFactory(
      () => VideoFelicitupBloc(
        felicitupRepository: di(),
      ),
    )
    ..registerFactory(
      () => BoteFelicitupBloc(
        felicitupRepository: di(),
      ),
    )
    ..registerFactory(
      () => PaymentBloc(
        felicitupRepository: di(),
        userRepository: di(),
      ),
    )
    ..registerFactory(
      () => VideoEditorBloc(),
    );
}
