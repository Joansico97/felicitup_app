part of './injection_container.dart';

void _initBlocsInjection() {
  di
    ..registerLazySingleton(
      () => AppBloc(
        userRepository: di(),
        authRepository: di(),
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
      ),
    )
    ..registerFactory(
      () => DetailsFelicitupDashboardBloc(),
    )
    ..registerFactory(
      () => InfoFelicitupBloc(),
    );
}
