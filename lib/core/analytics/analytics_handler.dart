import 'package:felicitup_app/helpers/facebook_analytics_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsHandler {
  AnalyticsHandler(this._firebaseAnalytics, this._facebookAnalyticsHelper);

  final FirebaseAnalytics _firebaseAnalytics;
  final FacebookAnalyticsHelper _facebookAnalyticsHelper;

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _firebaseAnalytics.logEvent(name: name, parameters: parameters);
    await _facebookAnalyticsHelper.logEvent(
      eventName: name,
      parameters: parameters,
    );
  }

  Future<void> logLogin() async {
    await _firebaseAnalytics.logLogin();
    await _facebookAnalyticsHelper.trackLogin();
  }

  Future<void> logSignUp({required String signUpMethod}) async {
    await _firebaseAnalytics.logSignUp(signUpMethod: signUpMethod);
    await _facebookAnalyticsHelper.trackCompleteRegistration();
  }

  Future<void> setCurrentScreen(String screenName) async {
    await _firebaseAnalytics.logScreenView(screenName: screenName);
  }

  Future<void> logActivateApp() async {
    await _facebookAnalyticsHelper.logActivateApp();
  }
}

class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver(this._analyticsHandler);

  final AnalyticsHandler _analyticsHandler;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _analyticsHandler.setCurrentScreen(route.settings.name ?? 'unknown');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _analyticsHandler.setCurrentScreen(newRoute?.settings.name ?? 'unknown');
  }
}
