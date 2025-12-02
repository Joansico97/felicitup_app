import 'dart:io';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:felicitup_app/core/utils/utils.dart';

class FacebookAnalyticsHelper {
  FacebookAnalyticsHelper() : _facebookAppEvents = FacebookAppEvents();

  final FacebookAppEvents _facebookAppEvents;

  /// Inicializa el SDK de Facebook
  Future<void> initialize() async {
    try {
      await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      logger.info('Facebook SDK initialized successfully');
    } catch (e) {
      logger.error('Error initializing Facebook SDK: $e');
    }
  }

  /// Rastrea la instalación de la app desde una campaña de Meta Ads
  Future<void> trackInstall() async {
    try {
      if (Platform.isAndroid) {
        await _trackAndroidInstall();
      } else if (Platform.isIOS) {
        await _trackIOSInstall();
      }
    } catch (e) {
      logger.error('Error tracking install: $e');
    }
  }

  /// Rastrea instalación en Android
  /// Nota: El SDK de Facebook rastrea automáticamente las instalaciones desde Meta Ads
  /// cuando está correctamente configurado con el App ID y Client Token.
  /// Play Install Referrer está configurado en build.gradle para soporte nativo.
  Future<void> _trackAndroidInstall() async {
    try {
      // El SDK de Facebook rastrea automáticamente las instalaciones desde Meta Ads
      // cuando la app se activa. Solo necesitamos logear el evento de activación.
      // El SDK internamente usa Play Install Referrer para detectar instalaciones.
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_activate_app',
        parameters: {'platform': 'android'},
      );

      // También logear como evento personalizado para tracking adicional
      await _facebookAppEvents.logEvent(
        name: 'app_install',
        parameters: {'platform': 'android'},
      );

      logger.info('Android install tracking initialized');
    } catch (e) {
      logger.error('Error tracking Android install: $e');
      // Aún así, intentar logear la activación de la app
      try {
        await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
      } catch (e2) {
        logger.error('Error logging activate app: $e2');
      }
    }
  }

  /// Rastrea instalación en iOS
  Future<void> _trackIOSInstall() async {
    try {
      // En iOS, el rastreo de instalación se maneja automáticamente
      // por el SDK de Facebook cuando se activa la app
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_activate_app',
        parameters: {'platform': 'ios'},
      );

      logger.info('iOS install tracked');
    } catch (e) {
      logger.error('Error tracking iOS install: $e');
    }
  }

  /// Logea un evento personalizado en Facebook Analytics
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: eventName,
        parameters: parameters ?? {},
      );
      logger.info('Facebook event logged: $eventName');
    } catch (e) {
      logger.error('Error logging Facebook event: $e');
    }
  }

  /// Logea la activación de la app (debe llamarse cada vez que la app se abre)
  Future<void> logActivateApp() async {
    try {
      await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
    } catch (e) {
      logger.error('Error logging activate app: $e');
    }
  }

  /// Establece el ID de usuario para rastreo
  Future<void> setUserId(String userId) async {
    try {
      await _facebookAppEvents.setUserID(userId);
      logger.info('Facebook user ID set: $userId');
    } catch (e) {
      logger.error('Error setting Facebook user ID: $e');
    }
  }

  /// Limpia el ID de usuario
  Future<void> clearUserId() async {
    try {
      await _facebookAppEvents.clearUserID();
    } catch (e) {
      logger.error('Error clearing Facebook user ID: $e');
    }
  }

  /// Rastrea el evento de instalación de la app
  Future<void> trackMobileInstall() async {
    await logEvent(eventName: 'fb_mobile_install');
  }

  /// Rastrea el evento de registro completo
  Future<void> trackCompleteRegistration() async {
    await logEvent(eventName: 'fb_mobile_complete_registration');
  }

  /// Rastrea el evento de visualización de contenido
  Future<void> trackViewContent() async {
    await logEvent(eventName: 'fb_mobile_view_content');
  }

  /// Rastrea el evento de inicio de sesión
  Future<void> trackLogin() async {
    await logEvent(eventName: 'fb_mobile_login');
  }
}
