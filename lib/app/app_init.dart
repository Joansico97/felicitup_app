import 'package:felicitup_app/helpers/facebook_analytics_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initFacebookSdk() async {
  final facebookAnalyticsHelper = FacebookAnalyticsHelper();
  await facebookAnalyticsHelper.initialize();
  
  final box = await Hive.openBox('app_settings');
  final bool isFirstRun = box.get('is_first_run', defaultValue: true);
  
  if (isFirstRun) {
    await facebookAnalyticsHelper.trackInstall();
    await box.put('is_first_run', false);
  }
}
