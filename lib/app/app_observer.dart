import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../core/utils/utils.dart';

class AppObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    logger.debug('Created (${bloc.runtimeType})');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    logger.debug('Changed (${bloc.runtimeType}, $change)');
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_change',
      parameters: {
        'screen_name': bloc.runtimeType.toString(),
        'bloc': bloc.runtimeType.toString(),
        'change': change.toString(),
      },
    );
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    logger.debug('Closed (${bloc.runtimeType})');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logger.error('Error (${bloc.runtimeType}, $error, $stackTrace)');
    FirebaseCrashlytics.instance.recordError(
      'Bloc: ${bloc.runtimeType} - Error: $error',
      stackTrace,
      fatal: true,
    );
  }
}
