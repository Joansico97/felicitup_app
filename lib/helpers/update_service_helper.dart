import 'dart:io' show Platform;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

class UpdateServiceHelper {
  UpdateServiceHelper({required FirebaseRemoteConfig remoteConfig})
    : _remoteConfig = remoteConfig;

  final FirebaseRemoteConfig _remoteConfig;

  static const String _defaultRequiredVersion = '1.0.0';

  Future<Map<String, dynamic>> checkVersion(BuildContext context) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Version currentVersion = Version.parse(packageInfo.version);
    late bool needToUpdate;
    late String updateMessage;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 20),
        minimumFetchInterval: Duration.zero,
      ),
    );
    await _remoteConfig.fetchAndActivate();

    String requiredVersionStr;
    if (Platform.isAndroid) {
      requiredVersionStr = _remoteConfig.getString('minimum_version_android');
    } else if (Platform.isIOS) {
      requiredVersionStr = _remoteConfig.getString('minimum_version_ios');
    } else {
      return {};
    }

    if (requiredVersionStr.isEmpty) {
      requiredVersionStr = _defaultRequiredVersion;
    }

    final Version requiredVersion = Version.parse(requiredVersionStr);

    if (currentVersion < requiredVersion) {
      updateMessage = _remoteConfig.getString('update_message');
      needToUpdate = true;
    } else {
      needToUpdate = false;
    }

    return {'needToUpdate': needToUpdate, 'updateMessage': updateMessage};
  }
}
