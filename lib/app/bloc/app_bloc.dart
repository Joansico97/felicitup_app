import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'app_event.dart';
part 'app_state.dart';
part 'app_bloc.freezed.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required FirebaseAuth firebaseAuth,
    required FirebaseMessaging firebaseMessaging,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _firebaseAuth = firebaseAuth,
       _firebaseMessaging = firebaseMessaging,
       super(AppState.initial()) {
    on<AppEvent>(
      (event, emit) => event.map(
        changeLoading: (_) => _changeLoading(emit),
        checkAppStatus: (_) => _checkAppStatus(emit),
        closeRememberSection: (_) => _closeRememberSection(emit),
        loadUserData: (_) => _loadUserData(emit),
        loadProvUserData:
            (event) => _loadProvUserData(emit, event.federatedData),
        updateMatchList: (event) => _updateMatchList(event.phoneList),
        initializeNotifications: (_) => _initializeNotifications(emit),
        requestManualPermissions: (_) => _requestManualPermissions(emit),
        deleterPermissions: (_) => _deleterPermissions(emit),
        handleRemoteMessage:
            (event) => handleRemoteMessage(event.message, emit),
        getFCMToken: (_) => _getFCMToken(),
        startGlobalTimer:
            (event) => _appEventStartGlobalTimer(emit, event.duration),
        stopGlobalTimer: (_) => _stopGlobalTimer(emit),
        globalTimerTick: (_) => _globalTimerTick(emit),
        logout: (_) => _logout(emit),
      ),
    );
  }

  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _firebaseMessaging;
  Timer? _globalTimer;

  _changeLoading(Emitter<AppState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _checkAppStatus(Emitter<AppState> emit) async {
    try {
      final response = await _userRepository.getAppVersionInfo();

      response.fold(
        (error) {
          logger.error('Error checking app status: $error');
        },
        (success) async {
          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final currentVersion =
              '${packageInfo.version}+${packageInfo.buildNumber}';
          if (success.first['appVersion'] != currentVersion) {
            rootNavigatorKey.currentContext!.go(RouterPaths.updatePage);
          }
        },
      );
    } catch (e) {
      logger.error('Error checking app status: $e');
    }
  }

  _closeRememberSection(Emitter<AppState> emit) {
    emit(state.copyWith(showRememberSection: false));
  }

  _loadUserData(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _userRepository.getUserData(
        _firebaseAuth.currentUser?.uid ?? '',
      );

      response.fold(
        (error) {
          logger.error(error);
          emit(state.copyWith(isLoading: false));
          add(const AppEvent.logout());
          rootNavigatorKey.currentContext!.go(RouterPaths.init);
        },
        (data) {
          final user = UserModel.fromJson(data);
          emit(state.copyWith(isLoading: false, currentUser: user));
        },
      );
    } catch (e) {
      logger.error(e);
      emit(state.copyWith(isLoading: false));
    }
  }

  _loadProvUserData(
    Emitter<AppState> emit,
    Map<String, dynamic> federatedData,
  ) {
    emit(state.copyWith(federatedData: federatedData));
  }

  _appEventStartGlobalTimer(Emitter<AppState> emit, Duration duration) {
    emit(
      state.copyWith(
        isGlobalTimerActive: true,
        globalTimerRemaining: duration,
        globalTimerInitialDuration: duration,
      ),
    );
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Agrega un evento interno para cada tick
      add(const AppEvent.globalTimerTick());
    });
  }

  _stopGlobalTimer(Emitter<AppState> emit) {
    _globalTimer?.cancel();
    emit(
      state.copyWith(
        isGlobalTimerActive: false,
        globalTimerRemaining: null,
        globalTimerInitialDuration: null,
      ),
    );
  }

  _globalTimerTick(Emitter<AppState> emit) {
    if (state.globalTimerRemaining != null &&
        state.globalTimerRemaining! > Duration.zero) {
      final newRemainingTime =
          state.globalTimerRemaining! - const Duration(seconds: 1);
      emit(state.copyWith(globalTimerRemaining: newRemainingTime));
    } else {
      _globalTimer?.cancel();
      emit(
        state.copyWith(
          isGlobalTimerActive: false,
          globalTimerRemaining: Duration.zero,
        ),
      );
    }
  }

  _updateMatchList(List<String> phonesList) async {
    List<String> phones = [...phonesList];

    final response = await _userRepository.getListUserDataByPhone(phones);

    return response.fold((l) => logger.error(l), (r) async {
      List<String> ids = [];
      for (final doc in r) {
        if (doc.id != null) {
          ids.add(doc.id!);
        }
      }
      await _userRepository.updateMatchList(ids);
    });
  }

  _requestManualPermissions(Emitter<AppState> emit) async {
    final settings = await _firebaseMessaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined ||
        settings.authorizationStatus == AuthorizationStatus.denied) {
      await requestPermission(emit);
    }
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      add(AppEvent.getFCMToken());
      emit(state.copyWith(status: AuthorizationStatus.authorized));
    }
  }

  _deleterPermissions(Emitter<AppState> emit) async {
    final settings = await _firebaseMessaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _firebaseMessaging.deleteToken();
      await _userRepository.setFCMToken('');
      emit(state.copyWith(status: AuthorizationStatus.denied));
    }
  }

  _initializeNotifications(Emitter<AppState> emit) async {
    final settings = await _firebaseMessaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      await requestPermission(emit);
    }
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      add(AppEvent.getFCMToken());
      emit(state.copyWith(status: AuthorizationStatus.authorized));
    }
    await initializeLocalNotifications();

    _onForegroundMessage(emit);
  }

  _logout(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.asignCurrentChatId('');
      await _authRepository.logout();
      emit(
        state.copyWith(
          isLoading: false,
          currentUser: null,
          isGlobalTimerActive: false,
          globalTimerRemaining: null,
          globalTimerInitialDuration: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      logger.info('FCM Token: $token');
      if (token != null) {
        await _userRepository.setFCMToken(token);
      }
    } catch (e) {
      logger.error(e);
    }
  }

  handleRemoteMessage(RemoteMessage message, Emitter<AppState> emit) {
    if (message.notification == null) return;

    final notification = PushMessageModel(
      messageId:
          message.messageId?.replaceAll(':', '').replaceAll('%', '') ??
          '${state.currentUser?.id}-${DateTime.now().millisecondsSinceEpoch}',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: DataMessageModel.fromJson(message.data),
    );

    Future.delayed(Duration.zero, () async {
      await _userRepository.syncNotifications(notification);
    });

    if (Platform.isAndroid) {
      showLocalNotification(
        id: notification.messageId.hashCode,
        title: notification.title,
        body: notification.body,
        data: message.data,
      );
    }
    if (Platform.isIOS) {
      darwinShowNotification(
        notification.messageId.hashCode,
        notification.title,
        notification.body,
        message.data,
      );
    }

    // emit(state.copyWith(notifications: [notification, ...state.notifications ?? []]));
  }

  void _onForegroundMessage(Emitter<AppState> emit) {
    FirebaseMessaging.onMessage.listen((message) {
      handleRemoteMessage(message, emit);
    });
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

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      emit(state.copyWith(status: AuthorizationStatus.authorized));
    }
  }

  initializeLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );
    final initializationSettingsIos = DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIos,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  darwinShowNotification(
    int id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
  ) {
    showLocalNotification(id: id, title: title, body: body, data: data);
  }

  showLocalNotification({
    required int id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
  }) {
    const androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentSound: true),
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  static void onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
    final resp = jsonDecode(response.payload ?? '{}');
    redirectHelper(data: resp);
  }
}
