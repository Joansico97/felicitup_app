import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_event.dart';
part 'app_state.dart';
part 'app_bloc.freezed.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required FirebaseAuth firebaseAuth,
    required FirebaseMessaging firebaseMessaging,
  })  : _userRepository = userRepository,
        _authRepository = authRepository,
        _firebaseAuth = firebaseAuth,
        _firebaseMessaging = firebaseMessaging,
        super(AppState.initial()) {
    on<AppEvent>(
      (event, emit) => event.map(
        changeLoading: (_) => _changeLoading(emit),
        loadUserData: (_) => _loadUserData(emit),
        initializeNotifications: (_) => _initializeNotifications(emit),
        logout: (_) => _logout(emit),
      ),
    );
  }

  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _firebaseMessaging;

  _changeLoading(Emitter<AppState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _loadUserData(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.getUserData(_firebaseAuth.currentUser?.uid ?? '');

      response.fold(
        (error) {
          emit(state.copyWith(isLoading: false));
        },
        (data) {
          emit(state.copyWith(
            isLoading: false,
            currentUser: UserModel.fromJson(data),
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _initializeNotifications(Emitter<AppState> emit) async {
    final settings = await _firebaseMessaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined ||
        settings.authorizationStatus == AuthorizationStatus.denied) {
      await requestPermission(emit);
    }
  }

  requestPermission(Emitter<AppState> emit) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // final notification = ref.read(localNotificationsProvider.notifier);
    // await notification.requestPermissionLocalNotifications();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      emit(state.copyWith(status: AuthorizationStatus.authorized));
    }
  }

  _logout(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.asignCurrentChatId('');
      await _authRepository.logout();
      emit(state.copyWith(
        isLoading: false,
        currentUser: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
