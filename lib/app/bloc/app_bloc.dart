import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
        handleRemoteMessage: (event) => handleRemoteMessage(event.message, emit),
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
    logger.debug('Loading user data');
    try {
      final response = await _userRepository.getUserData(_firebaseAuth.currentUser?.uid ?? '');

      response.fold(
        (error) {
          logger.error(error);
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
    await initializeLocalNotifications();
    _getFCMToken();
    _onForegroundMessage(emit);
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

  _getFCMToken() async {
    if (state.status == AuthorizationStatus.authorized) {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _userRepository.setFCMToken(token);
      }
    }
  }

  handleRemoteMessage(RemoteMessage message, Emitter<AppState> emit) {
    if (message.notification == null) return;

    final notification = PushMessageModel(
      messageId: message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: DataMessageModel.fromJson(message.data),
    );

    Future.delayed(
      Duration.zero,
      () {
        _userRepository.syncNotifications(notification);
      },
    );

    showLocalNotification(
      id: notification.messageId.hashCode,
      title: notification.title,
      body: notification.body,
      data: message.data,
    );

    emit(state.copyWith(notifications: [notification, ...state.notifications ?? []]));
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
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      emit(state.copyWith(status: AuthorizationStatus.authorized));
    }
  }

  initializeLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final initializationSettingsIos = DarwinInitializationSettings(
        // onDidReceiveLocalNotification: darwinShowNotification,
        );

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
      iOS: DarwinNotificationDetails(
        presentSound: true,
      ),
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

  static void onDidReceiveNotificationResponse(NotificationResponse response) async {
    final resp = jsonDecode(response.payload ?? '{}');
    final String type = resp['type'];
    final felicitupId = resp['felicitupId'] ?? '';
    final chatId = resp['chatId'] ?? '';
    final name = resp['name'] ?? '';
    final ids = resp['ids'] ?? [];
    final pushMessageType = pushMessageTypeToEnum(type);

    switch (pushMessageType) {
      case PushMessageType.felicitup:
        CustomRouter().router.go(
          RouterPaths.messageFelicitup,
          extra: {
            'felicitupId': felicitupId,
            'fromNotification': false,
          },
        );
        break;
      case PushMessageType.chat:
        CustomRouter().router.go(
          RouterPaths.messageFelicitup,
          extra: {
            'felicitupId': felicitupId,
            'fromNotification': false,
          },
        );
      case PushMessageType.payment:
        CustomRouter().router.go(
          RouterPaths.boteFelicitup,
          extra: {
            'felicitupId': felicitupId,
            'fromNotification': true,
          },
        );
      case PushMessageType.singleChat:
        CustomRouter().router.go(
          RouterPaths.singleChat,
          extra: {
            'chatId': chatId,
            'name': name,
            'ids': ids,
          },
        );
        break;
    }
  }
}
