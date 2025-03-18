part of './injection_container.dart';

void _initNetworkInjection() {
  di.registerLazySingleton<DatabaseHelper>(
    () => DatabaseHelper(),
  );
}
