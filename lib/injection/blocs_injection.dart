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
      ),
    )
    ..registerFactory(
      () => InfoFelicitupBloc(),
    )
    ..registerFactory(
      () => MessageFelicitupBloc(),
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
    );
}
