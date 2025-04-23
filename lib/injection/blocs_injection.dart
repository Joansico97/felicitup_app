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
    ..registerFactory(() => LoginBloc(authRepository: di(), firestore: di()))
    ..registerFactory(
      () => RegisterBloc(authRepository: di(), userRepository: di()),
    )
    ..registerFactory(() => HomeBloc(userRepository: di()))
    ..registerFactory(
      () => CreateFelicitupBloc(
        databaseHelper: di(),
        firebaseFunctionsHelper: di(),
        userRepository: di(),
        felicitupRepository: di(),
      ),
    )
    ..registerFactory(
      () => FelicitupsDashboardBloc(
        felicitupRepository: di(),
        chatRepository: di(),
        userRepository: di(),
        firebaseAuth: di(),
        localStorageHelper: di(),
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
      () => InfoFelicitupBloc(felicitupRepository: di(), userRepository: di()),
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
        userRepository: di(),
        firebaseAuth: di(),
      ),
    )
    ..registerFactory(() => VideoFelicitupBloc(felicitupRepository: di()))
    ..registerFactory(() => BoteFelicitupBloc(felicitupRepository: di()))
    ..registerFactory(
      () => PaymentBloc(felicitupRepository: di(), userRepository: di()),
    )
    ..registerFactory(
      () => VideoEditorBloc(
        userRepository: di(),
        felicitupRepository: di(),
        firebaseAuth: di(),
        firebaseFunctionsHelper: di(),
      ),
    )
    ..registerFactory(
      () => NotificationsBloc(firebaseAuth: di(), userRepository: di()),
    )
    ..registerFactory(() => ProfileBloc(userRepository: di()))
    ..registerFactory(() => WishListBloc(userRepository: di()))
    ..registerFactory(
      () => SingleChatBloc(chatRepository: di(), userRepository: di()),
    )
    ..registerFactory(() => ListSingleChatBloc())
    ..registerFactory(() => ContactsBloc(userRepository: di()))
    ..registerFactory(() => NotificationsSettingsBloc())
    ..registerFactory(() => FederatedRegisterBloc(userRepository: di()))
    ..registerFactory(() => TermsPoliciesBloc())
    ..registerFactory(
      () => DetailsPastFelicitupDashboardBloc(
        felicitupRepository: di(),
        userRepository: di(),
      ),
    )
    ..registerFactory(() => MainPastFelicitupBloc())
    ..registerFactory(
      () => ChatPastFelicitupBloc(
        felicitupRepository: di(),
        userRepository: di(),
        chatRepository: di(),
      ),
    )
    ..registerFactory(() => PeoplePastFelicitupBloc(felicitupRepository: di()))
    ..registerFactory(() => VideoPastFelicitupBloc())
    ..registerFactory(
      () => RemindersBloc(userRepository: di(), chatRepository: di()),
    );
}
