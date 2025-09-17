import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

part 'app_event.dart';
part 'app_state.dart';
part 'app_bloc.freezed.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required FirebaseAuth firebaseAuth,
    required FirebaseMessaging firebaseMessaging,
    required UpdateServiceHelper updateService,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _firebaseAuth = firebaseAuth,
       _firebaseMessaging = firebaseMessaging,
       _updateService = updateService,
       super(AppState.initial()) {
    on<AppEvent>(
      (event, emit) => event.map(
        onAppStarted: (_) => _onAppStarted(emit),
        checkAppStatus: (_) => _checkAppStatus(emit),
        closeRememberSection: (_) => _closeRememberSection(emit),
        loadUserData: (_) => _loadUserData(emit),
        syncContacts: (event) => _syncContacts(emit, event.isoCode),
        updateMatchListFromContacts: (_) => _updateMatchListFromContacts(emit),
        loadProvUserData: (event) =>
            _loadProvUserData(emit, event.federatedData),
        updateMatchList: (event) => _updateMatchList(event.phoneList),
        initializeNotifications: (_) => _initializeNotifications(emit),
        notificationReceived: (event) =>
            _notificationReceived(emit, event.payload),
        clearPendingNotification: (_) => clearPendingNotification(emit),
        requestManualPermissions: (_) => _requestManualPermissions(emit),
        deleterPermissions: (_) => _deleterPermissions(emit),
        handleRemoteMessage: (event) =>
            handleRemoteMessage(event.message, emit),
        getFCMToken: (_) => _getFCMToken(),
        startGlobalTimer: (event) =>
            _appEventStartGlobalTimer(emit, event.duration),
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
  final UpdateServiceHelper _updateService;
  Timer? _globalTimer;

  _onAppStarted(Emitter<AppState> emit) {
    add(const AppEvent.initializeNotifications());
    add(const AppEvent.loadUserData());
  }

  _checkAppStatus(Emitter<AppState> emit) async {
    try {
      final response = await _updateService.checkVersion(
        rootNavigatorKey.currentContext!,
      );

      if (response['needToUpdate'] as bool) {
        rootNavigatorKey.currentContext!.go(RouterPaths.updatePage);
        return;
      }
    } catch (e) {
      logger.error('Error checking app status: $e');
    }
  }

  _closeRememberSection(Emitter<AppState> emit) {
    emit(state.copyWith(showRememberSection: false));
  }

  _loadUserData(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));

    final userId = _firebaseAuth.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      final response = await _userRepository.getUserData(userId);

      response.fold(
        (error) {
          logger.error(error);
          emit(state.copyWith(isLoading: false));
          add(const AppEvent.logout());
          rootNavigatorKey.currentContext!.go(RouterPaths.init);
        },
        (data) {
          final user = UserModel.fromJson(data);
          if ((user.firstName == null || user.firstName!.isEmpty) &&
              (user.lastName == null || user.lastName!.isEmpty)) {
            rootNavigatorKey.currentContext!.go(RouterPaths.completeUserData);
          }
          emit(state.copyWith(isLoading: false, currentUser: user));
          add(AppEvent.syncContacts(user.isoCode ?? ''));
        },
      );
    } catch (e) {
      logger.error(e);
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _syncContacts(Emitter<AppState> emit, String isoCode) async {
    try {
      final List<HashedContact> contacts = await getHashedContacts(isoCode);
      final List<String> phones = contacts.map((c) => c.hashedPhone).toList();

      final response = await _userRepository.updateContacts(
        contacts
            .map((c) => {'displayName': c.displayName, 'phone': c.hashedPhone})
            .toList(),
        phones,
      );

      response.fold(
        (error) => logger.error('Failed to sync contacts: ${error.message}'),
        (_) {
          add(AppEvent.updateMatchListFromContacts());
        },
      );
      logger.info('Contacts synchronized successfully.');
    } catch (e) {
      logger.error('Error syncing contacts: $e');
    }
  }

  Future<void> _updateMatchListFromContacts(Emitter<AppState> emit) async {
    final friendsPhones = state.currentUser?.friendsPhoneList ?? [];
    if (friendsPhones.isEmpty) {
      logger.info('No friend phones to update match list.');
      return;
    }

    try {
      final response = await _userRepository.updateMatchListFromPhones(
        friendsPhones,
      );
      response.fold(
        (error) =>
            logger.error('Failed to update match list: ${error.message}'),
        (_) => logger.info('Match list updated from contacts successfully.'),
      );
    } catch (e) {
      logger.error('Error updating match list: $e');
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

  void _notificationReceived(
    Emitter<AppState> emit,
    Map<String, dynamic> payload,
  ) {
    emit(state.copyWith(pendingNotificationPayload: payload));
  }

  void clearPendingNotification(Emitter<AppState> emit) {
    emit(state.copyWith(pendingNotificationPayload: null));
  }

  _updateMatchList(List<String> phonesList) async {
    if (phonesList.isEmpty) return;

    try {
      final response = await _userRepository.updateMatchListFromPhones(
        phonesList,
      );

      response.fold((error) {
        logger.error('Error updating match list from phones: ${error.message}');
        ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Error updating match list: ${error.message}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }, (_) => logger.info('Match list updated successfully!'));
    } catch (e) {
      logger.error('An unexpected error occurred: $e');
    }
  }

  _requestManualPermissions(Emitter<AppState> emit) async {
    final settings = await _firebaseMessaging.getNotificationSettings();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
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

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
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
      await _userRepository.setFCMToken('');
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

  Future<List<HashedContact>> getHashedContacts(String isoCode) async {
    bool isGranted = await _checkContactsPermission();

    if (isGranted) {
      final packageContacts = await FastContacts.getAllContacts();

      List<HashedContact> hashedContacts = [];

      for (final contact in packageContacts) {
        if (contact.displayName.isEmpty || contact.phones.isEmpty) continue;

        String phoneNumber = contact.phones[0].number;
        if (phoneNumber.length < 8) continue;

        String normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

        if (!normalizedPhone.startsWith('+')) {
          normalizedPhone = '$isoCode$normalizedPhone';
        }

        final bytes = utf8.encode(normalizedPhone);
        final digest = sha256.convert(bytes);
        String hashedPhone = digest.toString();

        hashedContacts.add(
          HashedContact(
            displayName: contact.displayName,
            hashedPhone: hashedPhone,
          ),
        );
      }

      hashedContacts.sort(
        (a, b) => a.displayName.toLowerCase().trim().compareTo(
          b.displayName.toLowerCase().trim(),
        ),
      );

      return hashedContacts;
    }

    return [];
  }

  Future<bool> _checkContactsPermission() async {
    final contactsPermissionStatus = await Permission.contacts.status;

    if (!contactsPermissionStatus.isGranted) {
      final newPermissionStatus = await Permission.contacts.request();
      if (newPermissionStatus.isGranted || newPermissionStatus.isLimited) {
        return true;
      } else {
        return false;
      }
    } else if (contactsPermissionStatus.isPermanentlyDenied) {
      return false;
    } else {
      return true;
    }
  }
}
