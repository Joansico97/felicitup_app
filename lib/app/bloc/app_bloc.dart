import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
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
    required FacebookAnalyticsHelper facebookAnalyticsHelper,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _firebaseAuth = firebaseAuth,
       _firebaseMessaging = firebaseMessaging,
       _updateService = updateService,
       _facebookAnalyticsHelper = facebookAnalyticsHelper,
       super(AppState.initial()) {
    on<AppEvent>(
      (events, emit) => events.map(
        onAppStarted: (_) => _onAppStartedRequested(emit),
        changeLoadContacts: (_) => _onChangeLoadContacts(emit),
        loadContacts: (_) => _onLoadContacts(emit),
        checkAppStatus: (_) => _onCheckAppStatus(emit),
        closeRememberSection: (_) => _onCloseRememberSection(emit),
        loadUserData: (_) => _onLoadUserData(emit),

        updateMatchListFromContacts: (_) =>
            _onUpdateMatchListFromContacts(emit),
        loadProvUserData: (event) =>
            _onLoadProvUserData(emit, event.federatedData),
        initializeNotifications: (_) => _onInitializeNotifications(emit),
        notificationReceived: (event) =>
            _onNotificationReceived(emit, event.payload),
        clearPendingNotification: (_) => _onClearPendingNotification(emit),
        requestManualPermissions: (_) => _onRequestManualPermissions(emit),

        deleterPermissions: (_) => _onDeleterPermissions(emit),
        handleRemoteMessage: (event) =>
            handleRemoteMessage(event.message, emit),
        getFCMToken: (_) => _onGetFCMToken(),
        logout: (_) => _onLogout(emit),
      ),
    );
  }

  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _firebaseMessaging;
  final UpdateServiceHelper _updateService;
  final FacebookAnalyticsHelper _facebookAnalyticsHelper;

  void _onAppStartedRequested(Emitter<AppState> emit) {
    add(const AppEvent.initializeNotifications());
    add(const AppEvent.loadUserData());
  }

  void _onChangeLoadContacts(Emitter<AppState> emit) {
    emit(state.copyWith(reloadContacts: true));
  }

  Future<void> _onLoadContacts(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoadingContacts: true));

    try {
      final ids = state.currentUser?.friendsPhoneList ?? [];
      final friendList = state.currentUser?.friendList ?? [];
      final manualContacts = state.currentUser?.manualContacts ?? [];
      final contacts = [...friendList, ...manualContacts];

      if (ids.isEmpty || contacts.isEmpty) {
        emit(
          state.copyWith(
            isLoadingContacts: false,
            dataList: [],
            reloadContacts: false,
          ),
        );

        stream.listen((newState) {
          final newIds = newState.currentUser?.friendsPhoneList ?? [];
          final newFriendList = newState.currentUser?.friendList ?? [];
          if (newIds.isNotEmpty && newFriendList.isNotEmpty) {
            add(const AppEvent.loadContacts());

            late final StreamSubscription sub;
            sub = stream.listen((newState) {
              final newIds = newState.currentUser?.friendsPhoneList ?? [];
              final newFriendList = newState.currentUser?.friendList ?? [];
              if (newIds.isNotEmpty && newFriendList.isNotEmpty) {
                add(const AppEvent.loadContacts());
                sub.cancel();
              }
            });
          }
        });
        return;
      }

      final response = (!kIsWeb && Platform.isIOS)
          ? await _userRepository.getListUserDataByPhoneIos(ids)
          : await _userRepository.getListUserDataByPhone(ids);

      response.fold(
        (error) {
          logger.error('Failed to load contacts: $error');
          emit(
            state.copyWith(
              isLoadingContacts: false,
              dataList: [],
              reloadContacts: false,
            ),
          );
        },
        (registeredUsers) {
          final finalDataList = _processContactsData(contacts, registeredUsers);

          emit(
            state.copyWith(
              isLoadingContacts: false,
              dataList: finalDataList,
              reloadContacts: false,
            ),
          );
        },
      );
    } catch (e) {
      logger.error('Error loading contacts: $e');
      emit(
        state.copyWith(
          isLoadingContacts: false,
          dataList: [],
          reloadContacts: false,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _processContactsData(
    List<ContactModel> contacts,
    List<UserModel> registeredUsers,
  ) {
    final registeredPhonesSet = registeredUsers
        .map((user) => user.phone ?? '')
        .where((phone) => phone.isNotEmpty)
        .toSet();

    final registeredList = <Map<String, dynamic>>[];
    final unregisteredList = <Map<String, dynamic>>[];

    for (final contact in contacts) {
      final isRegistered = registeredPhonesSet.contains(contact.phone);
      final contactData = {'contact': contact, 'isRegistered': isRegistered};

      if (isRegistered) {
        registeredList.add(contactData);
      } else {
        unregisteredList.add(contactData);
      }
    }

    _sortContactsByName(registeredList);
    _sortContactsByName(unregisteredList);

    return [...registeredList, ...unregisteredList];
  }

  void _sortContactsByName(List<Map<String, dynamic>> contacts) {
    contacts.sort((a, b) {
      final aName = (a['contact'] as ContactModel).displayName ?? '';
      final bName = (b['contact'] as ContactModel).displayName ?? '';
      return aName.toLowerCase().compareTo(bName.toLowerCase());
    });
  }

  Future<void> _onCheckAppStatus(Emitter<AppState> emit) async {
    if (kIsWeb) return;

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

  void _onCloseRememberSection(Emitter<AppState> emit) {
    emit(state.copyWith(showRememberSection: false));
  }

  void _onLoadUserData(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));

    final userId = _firebaseAuth.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      final response = await _userRepository.getUserData(userId);

      return response.fold(
        (error) {
          logger.error(error);
          emit(state.copyWith(isLoading: false));
          add(const AppEvent.logout());
          rootNavigatorKey.currentContext!.go(RouterPaths.init);
        },
        (data) async {
          final user = UserModel.fromJson(data);
          if ((user.firstName == null || user.firstName!.isEmpty) &&
              (user.lastName == null || user.lastName!.isEmpty)) {
            rootNavigatorKey.currentContext!.go(RouterPaths.completeUserData);
          }
          emit(state.copyWith(isLoading: false, currentUser: user));

        },
      );
    } catch (e) {
      logger.error(e);
      emit(state.copyWith(isLoading: false));
    }
  }



  Future<void> _onUpdateMatchListFromContacts(Emitter<AppState> emit) async {
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

  void _onLoadProvUserData(
    Emitter<AppState> emit,
    Map<String, dynamic> federatedData,
  ) {
    emit(state.copyWith(federatedData: federatedData));
  }

  void _onNotificationReceived(
    Emitter<AppState> emit,
    Map<String, dynamic> payload,
  ) {
    emit(state.copyWith(pendingNotificationPayload: payload));
  }

  void _onClearPendingNotification(Emitter<AppState> emit) {
    emit(state.copyWith(pendingNotificationPayload: null));
  }

  Future<void> _onRequestManualPermissions(Emitter<AppState> emit) async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        await requestPermission(emit);
      } else {
        await _onNotificationPermissionGranted(emit);
      }
    } catch (e) {
      logger.error('Error requesting manual permissions: $e');
    }
  }



  void _onDeleterPermissions(Emitter<AppState> emit) async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await _firebaseMessaging.deleteToken();
        await _userRepository.setFCMToken('');
        emit(state.copyWith(status: AuthorizationStatus.denied));
      }
    } catch (e) {
      logger.error('Error deleting permissions: $e');
    }
  }

  void _onInitializeNotifications(Emitter<AppState> emit) async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        await requestPermission(emit);
      } else {
        await _onNotificationPermissionGranted(emit);
      }

      await initializeLocalNotifications();
      _onForegroundMessage(emit);
    } catch (e) {
      logger.error('Error initializing notifications: $e');
    }
  }

  Future<void> _onNotificationPermissionGranted(Emitter<AppState> emit) async {
    add(const AppEvent.getFCMToken());
    emit(state.copyWith(status: AuthorizationStatus.authorized));
  }

  void _onLogout(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.asignCurrentChatId('');
      await _userRepository.setFCMToken('');
      await _facebookAnalyticsHelper.clearUserId();
      await _authRepository.logout();
      emit(state.copyWith(isLoading: false, currentUser: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onGetFCMToken() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        final apnToken = await _firebaseMessaging.getAPNSToken();
        if (apnToken == null) {
          await Future.delayed(Duration(seconds: 3), () {
            final apnsTokenAfterDelay = _firebaseMessaging.getAPNSToken();
            apnsTokenAfterDelay
                .then((token) {
                  if (token == null) {
                    logger.error(
                      'No se pudo cargar el token APNS después del retraso',
                    );
                  }
                })
                .catchError((e) {
                  logger.error(
                    'Error obteniendo el token APNS después del retraso: $e',
                  );
                });
          });
        }
      }
      final token = await _firebaseMessaging.getToken();
      logger.info('FCM Token: $token');

      if (token != null && token.isNotEmpty) {
        await _userRepository.setFCMToken(token);
      } else {
        logger.info('FCM token is null or empty');
      }
    } catch (e) {
      logger.error('Error getting FCM token: $e');
    }
  }

  void handleRemoteMessage(RemoteMessage message, Emitter<AppState> emit) {
    if (message.notification == null) {
      logger.info('Received message without notification data');
      return;
    }

    try {
      final notification = _createPushMessageModel(message);

      _syncNotificationAsync(notification);

      _showPlatformSpecificNotification(notification, message.data);
    } catch (e) {
      logger.error('Error handling remote message: $e');
    }
  }

  PushMessageModel _createPushMessageModel(RemoteMessage message) {
    final messageId =
        message.messageId?.replaceAll(RegExp(r'[:%]'), '') ??
        '${state.currentUser?.id}-${DateTime.now().millisecondsSinceEpoch}';

    return PushMessageModel(
      messageId: messageId,
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: DataMessageModel.fromJson(message.data),
    );
  }

  void _syncNotificationAsync(PushMessageModel notification) {
    Future.delayed(Duration.zero, () async {
      try {
        await _userRepository.syncNotifications(notification);
      } catch (e) {
        logger.error('Error syncing notification: $e');
      }
    });
  }

  void _showPlatformSpecificNotification(
    PushMessageModel notification,
    Map<String, dynamic> data,
  ) {
    final notificationId = notification.messageId.hashCode;

    if (!kIsWeb && Platform.isAndroid) {
      showLocalNotification(
        id: notificationId,
        title: notification.title,
        body: notification.body,
        data: data,
      );
    } else if (!kIsWeb && Platform.isIOS) {
      darwinShowNotification(
        notificationId,
        notification.title,
        notification.body,
        data,
      );
    }
  }

  void _onForegroundMessage(Emitter<AppState> emit) {
    FirebaseMessaging.onMessage.listen((message) {
      add(AppEvent.handleRemoteMessage(message));
    });
  }

  Future<void> requestPermission(Emitter<AppState> emit) async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (!kIsWeb && Platform.isAndroid) {
        final flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        emit(state.copyWith(status: AuthorizationStatus.authorized));
      }
    } catch (e) {
      logger.error('Error requesting notification permission: $e');
    }
  }

  Future<void> initializeLocalNotifications() async {
    try {
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
        settings: initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );

      logger.info('Local notifications initialized successfully');
    } catch (e) {
      logger.error('Error initializing local notifications: $e');
    }
  }

  void darwinShowNotification(
    int id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
  ) {
    showLocalNotification(id: id, title: title, body: body, data: data);
  }

  void showLocalNotification({
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
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(data),
    );
  }

  static void onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
    final resp = jsonDecode(response.payload ?? '{}');
    redirectHelper(data: resp);
  }

  Future<List<HashedContact>> getHashedContacts(
    String isoCode,
    Emitter<AppState> emit,
  ) async {
    final permissionStatus = state.contactsPermissionStatus;

    if (!permissionStatus.isGranted && !permissionStatus.isLimited) {
      logger.info('Contacts permission not granted');
      return [];
    }

    try {
      List<Contact> packageContacts = [];

      if (permissionStatus.isLimited) {
        packageContacts = await FastContacts.getAllContacts();
        logger.info(
          'iOS limited permission: only shared contacts will be processed',
        );
      } else {
        packageContacts = await FastContacts.getAllContacts();
      }

      if (packageContacts.isEmpty) {
        logger.info('No contacts found on device');
        return [];
      }

      final hashedContacts = <HashedContact>[];
      final phoneRegex = RegExp(r'[^0-9+]');
      final minPhoneLength = 8;

      for (final contact in packageContacts) {
        if (contact.displayName.isEmpty || contact.phones.isEmpty) continue;

        final phoneNumber = contact.phones[0].number;
        if (phoneNumber.length < minPhoneLength) continue;

        final normalizedPhone = _normalizePhoneNumber(
          phoneNumber,
          isoCode,
          phoneRegex,
        );
        if (normalizedPhone == null) continue;

        final hashedPhone = _hashPhoneNumber(normalizedPhone);

        hashedContacts.add(
          HashedContact(
            displayName: contact.displayName,
            hashedPhone: hashedPhone,
          ),
        );
      }

      hashedContacts.sort(_compareContactNames);

      logger.info('Processed ${hashedContacts.length} contacts');
      return hashedContacts;
    } catch (e) {
      logger.error('Error getting hashed contacts: $e');
      return [];
    }
  }

  String? _normalizePhoneNumber(
    String phoneNumber,
    String isoCode,
    RegExp phoneRegex,
  ) {
    final normalizedPhone = phoneNumber.replaceAll(phoneRegex, '');

    if (normalizedPhone.isEmpty) return null;

    return normalizedPhone.startsWith('+')
        ? normalizedPhone
        : '$isoCode$normalizedPhone';
  }

  String _hashPhoneNumber(String phoneNumber) {
    final bytes = utf8.encode(phoneNumber);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  int _compareContactNames(HashedContact a, HashedContact b) {
    return a.displayName.toLowerCase().trim().compareTo(
      b.displayName.toLowerCase().trim(),
    );
  }


}
