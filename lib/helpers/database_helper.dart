import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  DatabaseHelper({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  String createId(
    String collection,
  ) {
    final collRef = _firestore.collection(collection);
    final docId = collRef.doc();
    return docId.id;
  }

  Future<dynamic> get(
    String collection, {
    String? document,
  }) async {
    try {
      if (document != null) {
        final response = await _firestore.collection(collection).doc(document).get();
        return response.data() ?? {};
      } else {
        final response = await _firestore.collection(collection).get();
        return response.docs.map((e) => e.data()).toList();
      }
    } catch (e) {
      return {};
    }
  }

  Future<void> set(
    String collection,
    Map<String, dynamic> data, {
    String? document,
  }) async {
    try {
      if (document != null) {
        await _firestore.collection(collection).doc(document).set(data);
      } else {
        await _firestore.collection(collection).add(data);
      }
    } catch (e) {
      return;
    }
  }

  Future<void> update(
    String collection,
    Map<String, dynamic> data, {
    required String document,
  }) async {
    try {
      await _firestore.collection(collection).doc(document).update(data);
    } catch (e) {
      return;
    }
  }

  Future<void> delete(
    String collection, {
    required String document,
  }) async {
    try {
      await _firestore.collection(collection).doc(document).delete();
    } catch (e) {
      return;
    }
  }
}
