import 'package:cloud_functions/cloud_functions.dart';
import 'package:felicitup_app/core/utils/utils.dart';

class FirebaseFunctionsHelper {
  FirebaseFunctionsHelper({required FirebaseFunctions firebaseFunctions})
    : _firebaseFunctions = firebaseFunctions;

  final FirebaseFunctions _firebaseFunctions;

  Future<void> logErrors({required String error}) async {
    await _call('logErrors', parameters: {'error': error});
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String currentChat,
    required Map<String, dynamic> data,
  }) async {
    await _call(
      'sendNotification',
      parameters: {
        'userId': userId,
        'title': title,
        'message': message,
        'currentChat': currentChat,
        'dataInfo': data,
      },
    );
  }

  Future<void> sendNotificationToList({
    required List<String> ids,
    required String title,
    required String message,
    required String currentChat,
    required Map<String, dynamic> data,
  }) async {
    await _call(
      'sendNotificationToList',
      parameters: {
        'userIds': ids,
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
      parameters: {
        'videoUrls': videoUrls,
        'felicitupId': felicitupId,
        'userId': userId,
      },
    );
  }

  Future<void> disableCurrentUser() async {
    await _call('disableCurrentUser');
  }

  Future<void> sendFelicitup({required String felicitupId}) async {
    try {
      final response = await _call<Map<String, dynamic>>(
        'sendFelicitup',
        parameters: {
          'felicitupId': felicitupId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      logger.info('Respuesta de sendFelicitup: $response');
    } catch (e) {
      logger.error('Error al enviar Felicitup, error: $e');
      rethrow;
    }
  }

  Future<void> sendManualFelicitup({required String felicitupId}) async {
    await _call(
      'sendManualFelicitup',
      parameters: {'felicitupId': felicitupId},
    );
  }

  Future<void> generateThumbnail({
    required String filePath,
    required String userId,
  }) async {
    await _call(
      'generateThumbnail',
      parameters: {'filePath': filePath, 'userId': userId},
    );
  }

  Future<T> _call<T>(
    String functionName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final callable = _firebaseFunctions.httpsCallable(
        functionName,
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );
      final HttpsCallableResult<dynamic> result = await callable.call(
        parameters ?? {},
      );
      return result.data as T;
    } on FirebaseFunctionsException catch (e) {
      logger.error('''
Firebase Functions Error:
  Function: $functionName
  Code: ${e.code}
  Details: ${e.details}
  Message: ${e.message}
''');
      rethrow;
    } catch (e, stack) {
      logger.error(
        'Unexpected error calling $functionName\n\nerror: $e\n\nstackTrace: $stack',
      );
      rethrow;
    }
  }
}
