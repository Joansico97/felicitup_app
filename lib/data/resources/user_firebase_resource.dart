import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserFirebaseResource implements UserRepository {
  UserFirebaseResource({
    required DatabaseHelper client,
    required FirebaseAuth firebaseAuth,
    required FirebaseStorage firebaseStorage,
    required FirebaseFunctionsHelper firebaseFunctionsHelper,
    required FirebaseFirestore firestore,
  })  : _client = client,
        _firebaseAuth = firebaseAuth,
        _firebaseStorage = firebaseStorage,
        _firebaseFunctionsHelper = firebaseFunctionsHelper,
        _firestore = firestore;

  final DatabaseHelper _client;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;
  final FirebaseFunctionsHelper _firebaseFunctionsHelper;
  final FirebaseFirestore _firestore;

  @override
  Future<Either<ApiException, Map<String, dynamic>>> getUserData(String userId) async {
    try {
      final response = await _client.get(
        AppConstants.usersCollection,
        document: userId,
      );
      if (response != null) {
        return Right(response);
      } else {
        return Left(ApiException(404, 'User not found'));
      }
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, Map<String, dynamic>>> getUserDataByPhone(String phone) async {
    try {
      final response = await _client.get(
        AppConstants.usersCollection,
      );
      if (response != null) {
        final user = response.firstWhere((user) => user['phone'] == phone, orElse: () => null);
        if (user != null) {
          return Right(user);
        } else {
          return Left(ApiException(404, 'User not found'));
        }
      } else {
        return Left(ApiException(404, 'No users found in collection'));
      }
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<Map<String, dynamic>>>> getListUserData(List<String> usersIds) async {
    try {
      final response = await _client.get(AppConstants.usersCollection);
      if (response != null) {
        final users = response as List<Map<String, dynamic>>;
        final usersData = users.where((user) => usersIds.contains(user['id'])).toList();
        return Right(usersData);
      } else {
        return Left(ApiException(404, 'Users not found'));
      }
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<UserModel>>> getListUserDataByPhone(List<String> phones) async {
    try {
      final List<UserModel> users = [];
      final List<Map<String, dynamic>> firebaseUsers = [];

      final response = await _client.get(AppConstants.usersCollection);

      if (response == null) {
        return Left(ApiException(404, 'Users not found'));
      }

      firebaseUsers.addAll(response);
      final Set<Map<String, dynamic>> usersSet = firebaseUsers.map((e) => e).toSet();
      List<Map<String, dynamic>> matchingUsers = usersSet.where((user) {
        return phones.any((phone) => user['phone'] == phone);
      }).toList();
      for (final user in matchingUsers) {
        users.add(UserModel.fromJson(user));
      }
      return Right(users);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> uploadFile(File file, String destination) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      final String imageFileName = "$uid/$destination/${uid}_$destination.jpg";
      Reference storageRef = _firebaseStorage.ref(imageFileName);
      final UploadTask imageUploadTask = storageRef.putFile(
        File(file.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await imageUploadTask;
      final String imageUrl = await storageRef.getDownloadURL();
      return Right(imageUrl);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, UserInvitedInformationModel>> getUserInvitedInformation(String id) async {
    try {
      final response = await _client.get(
        AppConstants.usersInvitedInformationCollection,
        document: id,
      );

      if (response != null) {
        return Right(UserInvitedInformationModel.fromJson(response));
      } else {
        return Left(ApiException(404, 'User not found'));
      }
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> sendNotification(
    String userId,
    String title,
    String message,
    String currentChat,
    DataMessageModel data,
  ) async {
    try {
      await _firebaseFunctionsHelper.sendNotification(
        userId: userId,
        title: title,
        message: message,
        currentChat: currentChat,
        data: data.toJson(),
      );

      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> sendNotificationToListUsers(
    List<String> ids,
    String title,
    String message,
    String currentChat,
    DataMessageModel data,
  ) async {
    try {
      await _firebaseFunctionsHelper.sendNotificationToList(
        ids: ids,
        title: title,
        message: message,
        currentChat: currentChat,
        data: data.toJson(),
      );

      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> asignCurrentChatId(String id) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _client.update(
        AppConstants.usersCollection,
        document: uid,
        {'currentChat': id},
      );
      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updateContacts(
    List<Map<String, dynamic>> contacts,
    List<String> phones,
  ) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _client.update(
        AppConstants.usersCollection,
        document: uid,
        {
          'friendList': contacts,
          'friendsPhoneList': phones,
        },
      );
      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updateMatchList(List<String> ids) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _client.update(
        AppConstants.usersCollection,
        document: uid,
        {
          'matchList': ids,
        },
      );
      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> createGiftItem(GiftcarModel item) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;

      await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
        'giftCardList': FieldValue.arrayUnion([item.toJson()]),
      });

      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteGiftItem(String id) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;

      await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
        'giftCardList': FieldValue.arrayRemove([id]),
      });

      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> editGiftItem(GiftcarModel item) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;

      await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
        'giftCardList': FieldValue.arrayUnion([item.toJson()]),
      });

      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> setFCMToken(String token) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _client.update(
        AppConstants.usersCollection,
        document: uid,
        {
          'fcmToken': token,
        },
      );
      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> syncNotifications(PushMessageModel notification) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
        'notifications': FieldValue.arrayUnion([notification.toJson()]),
      });
      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }
}
