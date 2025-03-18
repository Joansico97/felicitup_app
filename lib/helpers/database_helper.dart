import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class DatabaseHelper {
  String createId(
    String collection,
  ) {
    final collRef = firestore.FirebaseFirestore.instance.collection(collection);
    final docId = collRef.doc();
    return docId.id;
  }

  Future<dynamic> get(
    String collection, {
    String? document,
  }) async {
    try {
      if (document != null) {
        final response = await firestore.FirebaseFirestore.instance.collection(collection).doc(document).get();
        return response.data() ?? {};
      } else {
        final response = await firestore.FirebaseFirestore.instance.collection(collection).get();
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
        await firestore.FirebaseFirestore.instance.collection(collection).doc(document).set(data);
      } else {
        await firestore.FirebaseFirestore.instance.collection(collection).add(data);
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
      await firestore.FirebaseFirestore.instance.collection(collection).doc(document).update(data);
    } catch (e) {
      return;
    }
  }

  Future<void> delete(
    String collection, {
    required String document,
  }) async {
    try {
      await firestore.FirebaseFirestore.instance.collection(collection).doc(document).delete();
    } catch (e) {
      return;
    }
  }
}
