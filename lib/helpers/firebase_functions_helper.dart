import 'package:cloud_functions/cloud_functions.dart';
import 'package:felicitup_app/core/utils/utils.dart';

class FirebaseFunctionsHelper {
  FirebaseFunctionsHelper({
    required FirebaseFunctions firebaseFunctions,
  }) : _firebaseFunctions = firebaseFunctions;

  final FirebaseFunctions _firebaseFunctions;

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String currentChat,
    required Map<String, dynamic> data,
  }) async {
    await _call(
      'sendNotification',
      params: {
        'userId': userId,
        'title': title,
        'message': message,
        'currentChat': currentChat,
        'data': data,
      },
    );
  }

  Future<void> mergeVideos({
    required List<String> videoUrls,
    required String felicitupId,
    required String userId,
  }) async {
    await _call(
      'mergeVideos',
      params: {
        'videoUrls': videoUrls,
        'felicitupId': felicitupId,
        'userId': userId,
      },
    );
  }

  Future<void> sendManualFelicitup({
    required String felicitupId,
  }) async {
    await _call(
      'sendManualFelicitup',
      params: {
        'felicitupId': felicitupId,
      },
    );
  }

  Future<T> _call<T>(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final HttpsCallable callable = _firebaseFunctions.httpsCallable(functionName);
      final HttpsCallableResult<dynamic> result = await callable.call(params);
      return result.data as T;
    } catch (e) {
      logger.error('Error calling $functionName $e');
      rethrow;
    }
  }
}
