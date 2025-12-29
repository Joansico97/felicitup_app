import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:felicitup_app/core/utils/utils.dart';

class FacebookAnalyticsHelper {
  FacebookAnalyticsHelper() : _facebookAppEvents = FacebookAppEvents();

  final FacebookAppEvents _facebookAppEvents;

  Future<void> initialize() async {
    try {
      if (Platform.isIOS) {
        final status = await AppTrackingTransparency.requestTrackingAuthorization();
        if (status == TrackingStatus.authorized) {
          await _facebookAppEvents.setAdvertiserTracking(enabled: true);
        }
      } else {
        await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      }
      logger.info('Facebook SDK initialized successfully');
    } catch (e) {
      logger.error('Error initializing Facebook SDK: $e');
    }
  }

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

  Future<void> _trackAndroidInstall() async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_activate_app',
        parameters: {'platform': 'android'},
      );

      await _facebookAppEvents.logEvent(
        name: 'app_install',
        parameters: {'platform': 'android'},
      );

      logger.info('Android install tracking initialized');
    } catch (e) {
      logger.error('Error tracking Android install: $e');

      try {
        await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
      } catch (e2) {
        logger.error('Error logging activate app: $e2');
      }
    }
  }

  Future<void> _trackIOSInstall() async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_activate_app',
        parameters: {'platform': 'ios'},
      );

      logger.info('iOS install tracked');
    } catch (e) {
      logger.error('Error tracking iOS install: $e');
    }
  }

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

  Future<void> logActivateApp() async {
    try {
      await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
    } catch (e) {
      logger.error('Error logging activate app: $e');
    }
  }

  Future<void> setUserId(String userId) async {
    try {
      await _facebookAppEvents.setUserID(userId);
      logger.info('Facebook user ID set: $userId');
    } catch (e) {
      logger.error('Error setting Facebook user ID: $e');
    }
  }

  Future<void> clearUserId() async {
    try {
      await _facebookAppEvents.clearUserID();
    } catch (e) {
      logger.error('Error clearing Facebook user ID: $e');
    }
  }

  Future<void> trackMobileInstall() async {
    await logEvent(eventName: 'fb_mobile_install');
  }

  Future<void> trackCompleteRegistration() async {
    await logEvent(eventName: 'fb_mobile_complete_registration');
  }

  Future<void> trackViewContent() async {
    await logEvent(eventName: 'fb_mobile_view_content');
  }

  Future<void> trackLogin() async {
    await logEvent(eventName: 'fb_mobile_login');
  }
}
