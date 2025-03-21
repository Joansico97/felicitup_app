part of './injection_container.dart';

void _initBlocsInjection() {
  di
    ..registerLazySingleton(
      () => AppBloc(
        userRepository: di(),
        authRepository: di(),
        firebaseAuth: di(),
        firebaseMessaging: di(),
      ),
    )
    ..registerFactory(
      () => LoginBloc(
        authRepository: di(),
        firestore: di(),
      ),
    )
    ..registerFactory(
      () => RegisterBloc(
        authRepository: di(),
        userRepository: di(),
      ),
    )
    ..registerFactory(
      () => HomeBloc(
        userRepository: di(),
      ),
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
        userRepository: di(),
        firebaseAuth: di(),
      ),
    )
    ..registerFactory(
      () => FelicitupNotificationBloc(
        felicitupRepository: di(),
        userRepository: di(),
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
        firebaseFunctions: di(),
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
      () => VideoEditorBloc(
        userRepository: di(),
        felicitupRepository: di(),
      ),
    )
    ..registerFactory(
      () => NotificationsBloc(),
    )
    ..registerFactory(
      () => ProfileBloc(
        userRepository: di(),
      ),
    )
    ..registerFactory(
      () => WishListBloc(
        userRepository: di(),
      ),
    )
    ..registerFactory(
      () => SingleChatBloc(),
    )
    ..registerFactory(
      () => ListSingleChatBloc(),
    )
    ..registerFactory(
      () => ContactsBloc(
        userRepository: di(),
      ),
    )
    ..registerFactory(
      () => NotificationsSettingsBloc(),
    )
    ..registerFactory(
      () => FederatedRegisterBloc(
        userRepository: di(),
      ),
    )
    ..registerFactory(
      () => TermsPoliciesBloc(),
    );
}
