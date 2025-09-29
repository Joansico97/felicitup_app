import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _firebaseAuth = firebaseAuth,
       _firebaseMessaging = firebaseMessaging,
       _updateService = updateService,
       super(AppState.initial()) {
    on<AppEvent>(
      (events, emit) => events.map(
        onAppStarted: (_) => _onAppStarted(emit),
        changeLoadContacts: (_) => _changeLoadContacts(emit),
        loadContacts: (_) => _loadContacts(emit),
        checkAppStatus: (_) => _checkAppStatus(emit),
        closeRememberSection: (_) => _closeRememberSection(emit),
        loadUserData: (_) => _loadUserData(emit),
        syncContacts: (event) => _syncContacts(emit, event.isoCode),
        updateMatchListFromContacts: (_) => _updateMatchListFromContacts(emit),
        loadProvUserData: (event) =>
            _loadProvUserData(emit, event.federatedData),
        initializeNotifications: (_) => _initializeNotifications(emit),
        notificationReceived: (event) =>
            _notificationReceived(emit, event.payload),
        clearPendingNotification: (_) => clearPendingNotification(emit),
        requestManualPermissions: (_) => _requestManualPermissions(emit),
        requestManualContactsPermissions: (_) =>
            _requestManualContactsPermissions(emit),
        reseteContactsPermissions: (_) => _resetContactsPermissions(emit),
        deleterPermissions: (_) => _deleterPermissions(emit),
        handleRemoteMessage: (event) =>
            handleRemoteMessage(event.message, emit),
        getFCMToken: (_) => _getFCMToken(),
        logout: (_) => _logout(emit),
      ),
    );
  }

  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _firebaseMessaging;
  final UpdateServiceHelper _updateService;

  _onAppStarted(Emitter<AppState> emit) {
    add(const AppEvent.initializeNotifications());
    add(const AppEvent.loadUserData());
  }

  _changeLoadContacts(Emitter<AppState> emit) {
    emit(state.copyWith(reloadContacts: true));
  }

  _loadContacts(Emitter<AppState> emit) async {
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
        return;
      }

      final response = Platform.isIOS
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
    // Create a Set for O(1) lookup performance
    final registeredPhonesSet = registeredUsers
        .map((user) => user.phone ?? '')
        .where((phone) => phone.isNotEmpty)
        .toSet();

    // Separate contacts into registered and unregistered lists
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

    // Sort both lists by display name
    _sortContactsByName(registeredList);
    _sortContactsByName(unregisteredList);

    // Combine lists with registered contacts first
    return [...registeredList, ...unregisteredList];
  }

  void _sortContactsByName(List<Map<String, dynamic>> contacts) {
    contacts.sort((a, b) {
      final aName = (a['contact'] as ContactModel).displayName ?? '';
      final bName = (b['contact'] as ContactModel).displayName ?? '';
      return aName.toLowerCase().compareTo(bName.toLowerCase());
    });
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
          await _checkContactsPermission(emit);
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
      final List<HashedContact> contacts = await getHashedContacts(
        isoCode,
        emit,
      );

      if (contacts.isEmpty) {
        logger.info('No contacts to sync.');
        return;
      }

      // Prepare data for API call more efficiently
      final contactsData = contacts
          .map((c) => {'displayName': c.displayName, 'phone': c.hashedPhone})
          .toList();

      final phones = contacts.map((c) => c.hashedPhone).toList();

      final response = await _userRepository.updateContacts(
        contactsData,
        phones,
      );

      response.fold(
        (error) {
          logger.error('Failed to sync contacts: ${error.message}');
          emit(state.copyWith(isLoadingContacts: false));
        },
        (_) {
          logger.info('Contacts synchronized successfully.');
          // Chain the subsequent operations
          _onContactsSyncSuccess();
        },
      );
    } catch (e) {
      logger.error('Error syncing contacts: $e');
      emit(state.copyWith(isLoadingContacts: false));
    }
  }

  void _onContactsSyncSuccess() {
    add(const AppEvent.loadContacts());
    add(const AppEvent.updateMatchListFromContacts());
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

  void _notificationReceived(
    Emitter<AppState> emit,
    Map<String, dynamic> payload,
  ) {
    emit(state.copyWith(pendingNotificationPayload: payload));
  }

  void clearPendingNotification(Emitter<AppState> emit) {
    emit(state.copyWith(pendingNotificationPayload: null));
  }

  _requestManualPermissions(Emitter<AppState> emit) async {
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

  _requestManualContactsPermissions(Emitter<AppState> emit) async {
    try {
      if (state.contactsPermissionStatus.isGranted) {
        final currentUser = state.currentUser;
        if (currentUser != null && currentUser.isoCode != null) {
          add(AppEvent.syncContacts(currentUser.isoCode!));
        }
      }
    } catch (e) {
      logger.error('Error requesting manual contacts permissions: $e');
    }
  }

  _resetContactsPermissions(Emitter<AppState> emit) async {
    try {
      final response = await Permission.contacts.request();

      if (response.isGranted || response.isLimited) {
        await openAppSettings();
        return;
      } else if (response.isDenied) {
        final newStatus = await Permission.contacts.request();
        emit(state.copyWith(contactsPermissionStatus: newStatus));

        if (newStatus.isGranted) {
          _syncContactsIfUserAvailable();
        }
      } else {
        await openAppSettings();
      }
    } catch (e) {
      logger.error('Error resetting contacts permissions: $e');
    }
  }

  void _syncContactsIfUserAvailable() {
    final currentUser = state.currentUser;
    if (currentUser != null && currentUser.isoCode != null) {
      add(AppEvent.syncContacts(currentUser.isoCode!));
    }
  }

  _deleterPermissions(Emitter<AppState> emit) async {
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

  _initializeNotifications(Emitter<AppState> emit) async {
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

  _logout(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.asignCurrentChatId('');
      await _userRepository.setFCMToken('');
      await _authRepository.logout();
      emit(state.copyWith(isLoading: false, currentUser: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _getFCMToken() async {
    try {
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

  handleRemoteMessage(RemoteMessage message, Emitter<AppState> emit) {
    if (message.notification == null) {
      logger.info('Received message without notification data');
      return;
    }

    try {
      final notification = _createPushMessageModel(message);

      // Sync notification asynchronously
      _syncNotificationAsync(notification);

      // Show local notification based on platform
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

    if (Platform.isAndroid) {
      showLocalNotification(
        id: notificationId,
        title: notification.title,
        body: notification.body,
        data: data,
      );
    } else if (Platform.isIOS) {
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
      handleRemoteMessage(message, emit);
    });
  }

  requestPermission(Emitter<AppState> emit) async {
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

      // Request Android-specific permissions
      if (Platform.isAndroid) {
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

  initializeLocalNotifications() async {
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
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );

      logger.info('Local notifications initialized successfully');
    } catch (e) {
      logger.error('Error initializing local notifications: $e');
    }
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

  Future<List<HashedContact>> getHashedContacts(
    String isoCode,
    Emitter<AppState> emit,
  ) async {
    if (!state.contactsPermissionStatus.isGranted) {
      logger.info('Contacts permission not granted');
      return [];
    }

    try {
      final packageContacts = await FastContacts.getAllContacts();

      if (packageContacts.isEmpty) {
        logger.info('No contacts found on device');
        return [];
      }

      final hashedContacts = <HashedContact>[];
      final phoneRegex = RegExp(r'[^0-9+]');
      final minPhoneLength = 8;

      for (final contact in packageContacts) {
        // Skip contacts without name or phone
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

      // Sort contacts by display name
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

  Future<void> _checkContactsPermission(Emitter<AppState> emit) async {
    final contactsPermissionStatus = await Permission.contacts.status;

    if (contactsPermissionStatus.isGranted ||
        contactsPermissionStatus.isLimited) {
      emit(state.copyWith(contactsPermissionStatus: contactsPermissionStatus));
    } else if (contactsPermissionStatus.isPermanentlyDenied) {
      emit(state.copyWith(contactsPermissionStatus: contactsPermissionStatus));
    } else {
      final newPermissionStatus = await Permission.contacts.request();
      emit(state.copyWith(contactsPermissionStatus: newPermissionStatus));
    }
  }
}
