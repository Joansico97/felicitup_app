import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/utils/utils.dart';

class LocalStorageHelper {
  LocalStorageHelper();

  final HiveInterface _hive = Hive;

  Future<void> init() async {
    await _hive.initFlutter();
    await _hive.openBox<String>('defaultBox');
  }

  Future<void> clear() async {
    _clearBox<String>('defaultBox');
  }

  Future<String?> read({required String key}) {
    return _getFromBox<String>('defaultBox', key).onError((error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        'Read Hive Error: $error',
        stackTrace,
        fatal: true,
      );
      return null;
    });
  }

  Future<void> update({required String key, required String value}) {
    return _put<String>('defaultBox', key, value).onError((error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        'Update Hive Error: $error',
        stackTrace,
        fatal: true,
      );
    });
  }

  Future<void> write({required String key, required String value}) async {
    _addToBox<String>('defaultBox', key, value).onError((error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        'Write Hive Error: $error',
        stackTrace,
        fatal: true,
      );
    });
  }

  Future<void> delete({required String key}) async {
    _deleteFromBox<String>('defaultBox', key).onError((error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        'Delete Hive Error: $error',
        stackTrace,
        fatal: true,
      );
    });
  }

  /// Clear all values in the box with the given boxName.
  Future<void> _clearBox<T>(String boxName) async =>
      _hive.box<T>(boxName).clear();

  /// Get a value from the box with the given boxName using the id.
  Future<T?> _getFromBox<T>(String boxName, String? id) async =>
      _hive.box<T>(boxName).get(id);

  /// Update a value in the box with the given boxName
  /// only if the value hash has changed
  Future<void> _put<T>(String boxName, String? id, T value) async {
    final box = _hive.box<T>(boxName);
    final existingObject = box.get(id);

    if (existingObject != null && existingObject.hashCode == value.hashCode) {
      logger.error(
        'The object with Id $id has not changed. '
        'No need to be updated in the box $boxName.',
      );
      return;
    }
    await box.put(id, value);
  }

  /// Add a value to the box with the given boxName.
  /// If the id already exists, log an info message
  Future<void> _addToBox<T>(String boxName, String id, T value) async {
    final box = _hive.box<T>(boxName);
    await box.put(id, value);
  }

  /// Delete a value in the box with the given boxName] using the id.
  Future<void> _deleteFromBox<T>(String boxName, String id) async =>
      _hive.box<T>(boxName).delete(id);
}
