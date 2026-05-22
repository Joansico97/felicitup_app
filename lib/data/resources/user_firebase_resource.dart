import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class UserFirebaseResource implements UserRepository {
  UserFirebaseResource({
    required DatabaseHelper client,
    required FirebaseAuth firebaseAuth,
    required FirebaseStorage firebaseStorage,
    required FirebaseFunctionsHelper firebaseFunctionsHelper,
    required FirebaseFirestore firestore,
  }) : _client = client,
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
  Future<Either<ApiException, Map<String, dynamic>>> getUserData(
    String userId,
  ) {
    return _executeFirebaseOperation(() async {
      final response = await _client.get(
        AppConstants.usersCollection,
        document: userId,
      );
      if (response != null) {
        return response;
      } else {
        throw ApiException(404, 'User not found');
      }
    });
  }

  @override
  Future<Either<ApiException, bool>> checkPhoneExist({required String phone}) {
    return _executeFirebaseOperation(() async {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    });
  }

  @override
  Future<Either<ApiException, bool>> checkEmailExist({required String email}) {
    return _executeFirebaseOperation(() async {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    });
  }

  @override
  Future<Either<ApiException, void>> sendVerifyEmail() {
    return _executeFirebaseOperation(() async {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ApiException(
          401,
          'User not authenticated to send verification email',
        );
      }

      final maxRetries = 3;
      final initialDelay = Duration(seconds: 1);
      for (var i = 0; i < maxRetries; i++) {
        try {
          await user.sendEmailVerification();

          return;
        } on FirebaseException catch (e) {
          if (e.code == 'too-many-requests' && i < maxRetries - 1) {
            final delay = initialDelay * (i + 1);
            await Future.delayed(delay);
            continue;
          }

          rethrow;
        }
      }

      throw ApiException(429, 'Too many requests, please try again later.');
    });
  }

  @override
  Future<Either<ApiException, Map<String, dynamic>>> getUserDataByPhone(
    String phone,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();
        userData['id'] = userDoc.id;
        return Right(userData);
      } else {
        return Left(ApiException(404, 'User not found'));
      }
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<Map<String, dynamic>>>> getListUserData(
    List<String> usersIds,
  ) async {
    try {
      if (usersIds.isEmpty) {
        return const Right([]);
      }

      final chunks = usersIds.slices(30);

      final futures = chunks.map((chunk) {
        return _firestore
            .collection(AppConstants.usersCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
      }).toList();

      final snapshots = await Future.wait(futures);

      final List<Map<String, dynamic>> usersData = [];
      for (final snapshot in snapshots) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          usersData.add(data);
        }
      }

      if (usersData.isEmpty) {
        return Left(ApiException(404, 'No users found for the given IDs'));
      }

      return Right(usersData);
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<UserModel>>> getListUserDataByPhone(
    List<String> phones,
  ) {
    return _executeFirebaseOperation(() async {
      if (phones.isEmpty) {
        return <UserModel>[];
      }

      final List<UserModel> users = [];
      final chunks = phones.slices(30);

      for (final chunk in chunks) {
        final querySnapshot = await _firestore
            .collection(AppConstants.usersCollection)
            .where('phone', whereIn: chunk)
            .get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          users.add(UserModel.fromJson(data));
        }
      }
      return users;
    });
  }

  @override
  Future<Either<ApiException, List<UserModel>>> getListUserDataByPhoneIos(
    List<String> phones,
  ) async {
    try {
      final List<UserModel> users = [];
      final List<Map<String, dynamic>> firebaseUsers = [];

      final response = await _client.get(AppConstants.usersCollection);

      if (response == null) {
        return Left(ApiException(404, 'Users not found'));
      }

      firebaseUsers.addAll(response);
      final Set<Map<String, dynamic>> usersSet = firebaseUsers
          .map((e) => e)
          .toSet();
      List<Map<String, dynamic>> matchingUsers = usersSet.where((user) {
        return phones.any((phone) => user['phone'] == phone);
      }).toList();

      for (final user in matchingUsers) {
        users.add(UserModel.fromJson(user));
      }
      return Right(users);
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> uploadFile(
    File file,
    String destination,
  ) {
    return _executeFirebaseOperation(() async {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      final uuid = const Uuid().v4();
      final String imageFileName = "$uid/$destination/$uuid.jpg";
      Reference storageRef = _firebaseStorage.ref(imageFileName);

      await storageRef.putFile(
        File(file.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return storageRef.getDownloadURL();
    });
  }

  @override
  Future<Either<ApiException, String>> uploadVideoFile(
    File file,
    String destination,
    String id,
  ) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      final String videoFileName = "$uid/$destination/${uid}_$id.mp4";
      Reference storageRef = _firebaseStorage.ref(videoFileName);
      final UploadTask videoUploadTask = storageRef.putFile(
        File(file.path),
        SettableMetadata(contentType: 'video/mp4'),
      );
      await videoUploadTask;
      final String videoUrl = await storageRef.getDownloadURL();
      return Right(videoUrl);
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, UserInvitedInformationModel>>
  getUserInvitedInformation(String id) {
    return _executeFirebaseOperation(() async {
      final response = await _client.get(
        AppConstants.usersInvitedInformationCollection,
        document: id,
      );

      if (response != null) {
        return UserInvitedInformationModel.fromJson(response);
      } else {
        throw ApiException(404, 'User not found');
      }
    });
  }

  @override
  Future<Either<ApiException, void>> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String currentChat,
    required DataMessageModel data,
  }) {
    return _executeFirebaseOperation(
      () => _firebaseFunctionsHelper.sendNotification(
        userId: userId,
        title: title,
        message: message,
        currentChat: currentChat,
        data: data.toJson(),
      ),
    );
  }

  @override
  Future<Either<ApiException, void>> sendNotificationToListUsers(
    List<String> ids,
    String title,
    String message,
    String currentChat,
    DataMessageModel data,
  ) {
    return _executeFirebaseOperation(
      () => _firebaseFunctionsHelper.sendNotificationToList(
        ids: ids,
        title: title,
        message: message,
        currentChat: currentChat,
        data: data.toJson(),
      ),
    );
  }

  @override
  Future<Either<ApiException, void>> asignCurrentChatId(String id) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      return _client.update(AppConstants.usersCollection, document: uid, {
        'currentChat': id,
      });
    });
  }

  @override
  Future<Either<ApiException, void>> completeeUserInfo(
    String firstName,
    String lastName,
  ) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      final userDocRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid);

      return _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userDocRef);

        if (!userDoc.exists) {
          throw ApiException(404, 'User not found');
        }

        transaction.update(userDocRef, {
          'firstName': firstName,
          'lastName': lastName,
          'fullName': '$firstName $lastName',
        });
      });
    });
  }

  @override
  Future<Either<ApiException, void>> updateUserInfo(UserModel user) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      final userDocRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid);

      return _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userDocRef);

        if (!userDoc.exists) {
          throw ApiException(404, 'User not found');
        }

        transaction.update(userDocRef, {
          'firstName': user.firstName,
          'lastName': user.lastName,
          'phone': user.phone,
          'isoCode': user.isoCode,
          'fullName': '${user.firstName} ${user.lastName}',
          'birthDate': user.birthDate?.toUtc(),
          'birthDay': user.birthDay,
          'birthMonth': user.birthMonth,
        });
      });
    });
  }

  @override
  Future<Either<ApiException, void>> updateContacts(
    List<Map<String, dynamic>> contacts,
    List<String> phones,
  ) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      return _client.update(AppConstants.usersCollection, document: uid, {
        'friendList': contacts,
        'friendsPhoneList': phones,
      });
    });
  }

  @override
  Future<Either<ApiException, void>> updateMatchList(List<String> ids) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      return _client.update(AppConstants.usersCollection, document: uid, {
        'matchList': ids,
      });
    });
  }

  @override
  Future<Either<ApiException, void>> updateMatchListFromPhones(
    List<String> phones,
  ) {
    return _executeFirebaseOperation(() async {
      if (phones.isEmpty) {
        return;
      }

      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }

      final List<String> userIds = [];
      final chunks = phones.slices(30);
      for (final chunk in chunks) {
        final querySnapshot = await _firestore
            .collection(AppConstants.usersCollection)
            .where('phone', whereIn: chunk)
            .get();

        for (final doc in querySnapshot.docs) {
          userIds.add(doc.id);
        }
      }

      if (userIds.isNotEmpty) {
        await _client.update(AppConstants.usersCollection, document: uid, {
          'matchList': userIds,
        });
      }
    });
  }

  @override
  Future<Either<ApiException, void>> updateUserImageFromFile(File file) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }

      final uploadResult = await uploadFile(file, 'profile');

      return await uploadResult.fold(
        (apiException) async => Left(apiException),
        (url) async {
          try {
            await _client.update(AppConstants.usersCollection, document: uid, {
              'userImg': url,
            });
            return Right(null);
          } on FirebaseException catch (e) {
            return Left(
              ApiException(int.parse(e.code), e.message ?? 'Error de Firebase'),
            );
          } catch (e) {
            return Left(ApiException(1000, e.toString()));
          }
        },
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updateUserImageFromUrl(String url) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      return _client.update(AppConstants.usersCollection, document: uid, {
        'userImg': url,
      });
    });
  }

  @override
  Future<Either<ApiException, void>> createGiftItem(GiftcarModel item) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;

      await _firestore.collection(AppConstants.usersCollection).doc(uid).update(
        {
          'giftcardList': FieldValue.arrayUnion([item.toJson()]),
        },
      );

      return Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteGiftItem(String id) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      return Left(ApiException(401, "Usuario no autenticado"));
    }
    final userDocRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid);

    return FirebaseFirestore.instance.runTransaction<
      Either<ApiException, void>
    >((transaction) async {
      try {
        final userDoc = await transaction.get(userDocRef);
        if (!userDoc.exists) {
          return Left(ApiException(404, "Usuario no encontrado"));
        }

        final giftcardList =
            userDoc.data()?['giftcardList'] as List<dynamic>? ?? [];

        final updatedList = giftcardList
            .where((item) => (item is Map ? item['id'] != id : item != id))
            .toList();

        if (updatedList.length == giftcardList.length) {
          return Left(ApiException(404, "Elemento no encontrado en la lista"));
        }

        transaction.update(userDocRef, {'giftcardList': updatedList});
        return Right(null);
      } catch (e) {
        return Left(ApiException(500, "Error desconocido: ${e.toString()}"));
      }
    });
  }

  @override
  Future<Either<ApiException, void>> deleteReminder(String id) async {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      return Left(ApiException(401, "Usuario no autenticado"));
    }

    final userDocRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid);

    return FirebaseFirestore.instance.runTransaction<
      Either<ApiException, void>
    >((transaction) async {
      try {
        final userDoc = await transaction.get(userDocRef);

        if (!userDoc.exists) {
          return Left(ApiException(404, "Usuario no encontrado"));
        }

        final userData = userDoc.data();
        if (userData == null) {
          return Left(
            ApiException(404, "Error al obtener la información del usuario"),
          );
        }
        final birthdateAlerts =
            userData['birthdateAlerts'] as List<dynamic>? ?? [];

        final indexToRemove = birthdateAlerts.indexWhere((item) {
          if (item is String) {
            return item == id;
          } else if (item is Map) {
            return item['id'] == id;
          }
          return false;
        });

        if (indexToRemove == -1) {
          return Left(ApiException(404, "Elemento no encontrado en la lista"));
        }

        final updatedList = List<dynamic>.from(birthdateAlerts);
        final itemToRemove = updatedList.removeAt(indexToRemove);

        transaction.update(userDocRef, {
          'birthdateAlerts': FieldValue.arrayRemove([itemToRemove]),
        });

        return Right(null);
      } on FirebaseException catch (e) {
        return Left(
          ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
        );
      } catch (e) {
        return Left(ApiException(500, "Error desconocido: ${e.toString()}"));
      }
    });
  }

  @override
  Future<Either<ApiException, void>> editGiftItem({
    required String itemId,
    String? newProductName,
    String? newProductValue,
    String? newProductDescription,
    List<String>? newLinks,
  }) async {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      return Left(ApiException(401, "Usuario no autenticado"));
    }

    final userDocRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid);

    return FirebaseFirestore.instance.runTransaction<
      Either<ApiException, void>
    >((transaction) async {
      try {
        final userDoc = await transaction.get(userDocRef);

        if (!userDoc.exists) {
          return Left(ApiException(404, "Usuario no encontrado"));
        }

        final userData = userDoc.data();
        if (userData == null) {
          return Left(
            ApiException(404, "No se pudieron obtener los datos del usuario."),
          );
        }

        final giftcardList = userData['giftcardList'] as List<dynamic>? ?? [];

        final itemIndex = giftcardList.indexWhere((item) {
          if (item is Map<String, dynamic>) {
            return item['id'] == itemId;
          }
          return false;
        });

        if (itemIndex == -1) {
          return Left(ApiException(404, "Ítem no encontrado"));
        }

        final updatedList = List<dynamic>.from(giftcardList);

        final Map<String, dynamic> updatedItem = Map.from(
          updatedList[itemIndex] as Map<String, dynamic>,
        );

        if (newProductName != null) {
          updatedItem['productName'] = newProductName;
        }
        if (newProductValue != null) {
          updatedItem['productValue'] = newProductValue;
        }
        if (newProductDescription != null) {
          updatedItem['productDescription'] = newProductDescription;
        }
        if (newLinks != null) {
          updatedItem['links'] = newLinks;
        }

        updatedList[itemIndex] = updatedItem;

        transaction.update(userDocRef, {'giftcardList': updatedList});

        return Right(null);
      } on FirebaseException catch (e) {
        return Left(
          ApiException(int.parse(e.code), e.message ?? "Error de firebase"),
        );
      } catch (e) {
        return Left(ApiException(500, "Error desconocido: ${e.toString()}"));
      }
    });
  }

  @override
  Future<Either<ApiException, void>> setFCMToken(String token) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      return _client.update(AppConstants.usersCollection, document: uid, {
        'fcmToken': token,
      });
    });
  }

  @override
  Future<Either<ApiException, void>> syncNotifications(
    PushMessageModel notification,
  ) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      final notificationMap = {
        'title': notification.title,
        'body': notification.body,
        'sentDate': notification.sentDate,
        'data': notification.data?.toJson(),
      };
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update(
        {
          'notifications': FieldValue.arrayUnion([notificationMap]),
        },
      );

      return Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> setInitialUserInfo(UserModel user) async {
    try {
      final uid = user.id;
      await _client.set(
        AppConstants.usersCollection,
        document: uid,
        user.toJson(),
      );
      return Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> setUserInfoRemaining(
    String name,
    String lastName,
    String phone,
    String isoCode,
    String genre,
  ) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      return _client.update(AppConstants.usersCollection, document: uid, {
        'firstName': name,
        'lastName': lastName,
        'fullName': '$name $lastName',
        'phone': phone,
        'isoCode': isoCode,
        'genre': genre,
        'birthDate': null,
        'birthDay': null,
        'birthMonth': null,
        'birthdateAlerts': [],
        'singleChats': [],
      });
    });
  }

  @override
  Future<Either<ApiException, void>> setUserPhone(
    String phone,
    String isoCode,
    String userId,
  ) {
    return _executeFirebaseOperation(
      () => _client.update(AppConstants.usersCollection, document: userId, {
        'phone': phone,
        'isoCode': isoCode,
      }),
    );
  }

  @override
  Future<Either<ApiException, void>> setFederatedData({
    required String firstName,
    required String lastName,
    DateTime? birthDate,
  }) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }
      return _client.update(AppConstants.usersCollection, document: uid, {
        'firstName': firstName,
        'lastName': lastName,
        'fullName': '$firstName $lastName',
        'birthDate': birthDate?.toUtc(),
        'birthDay': birthDate?.day,
        'birthMonth': birthDate?.month,
        'birthdateAlerts': [],
        'singleChats': [],
      });
    });
  }

  @override
  Future<Either<ApiException, void>> deleteNotification(
    String notificationId,
  ) async {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      return Left(ApiException(401, "Usuario no autenticado"));
    }

    final userDocRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid);

    return FirebaseFirestore.instance.runTransaction<
      Either<ApiException, void>
    >((transaction) async {
      try {
        final userDoc = await transaction.get(userDocRef);

        if (!userDoc.exists) {
          return Left(ApiException(404, "Usuario no encontrado"));
        }

        final userData = userDoc.data();
        if (userData == null) {
          return Left(
            ApiException(404, "Error al obtener la información del usuario"),
          );
        }
        final notificationsList =
            userData['notifications'] as List<dynamic>? ?? [];

        final indexToRemove = notificationsList.indexWhere((item) {
          if (item is String) {
            return item == notificationId;
          } else if (item is Map) {
            return item['messageId'] == notificationId;
          }
          return false;
        });

        if (indexToRemove == -1) {
          return Left(ApiException(404, "Elemento no encontrado en la lista"));
        }

        final updatedList = List<dynamic>.from(notificationsList);
        final itemToRemove = updatedList.removeAt(indexToRemove);

        transaction.update(userDocRef, {
          'notifications': FieldValue.arrayRemove([itemToRemove]),
        });

        return Right(null);
      } on FirebaseException catch (e) {
        return Left(
          ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
        );
      } catch (e) {
        return Left(ApiException(500, "Error desconocido: ${e.toString()}"));
      }
    });
  }

  @override
  Future<Either<ApiException, void>> updateUserBirthdate(DateTime date) {
    return _executeFirebaseOperation(() {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, "Usuario no autenticado");
      }
      final userDocRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid);

      return _firestore.runTransaction<void>((transaction) async {
        final userDoc = await transaction.get(userDocRef);

        if (!userDoc.exists) {
          throw ApiException(404, "Usuario no encontrado");
        }

        transaction.update(userDocRef, {
          'birthDate': date.toUtc(),
          'birthDay': date.day,
          'birthMonth': date.month,
        });
      });
    });
  }

  @override
  Stream<Either<ApiException, List<GiftcarModel>>> getGiftcardListStream() {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      return _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .snapshots()
          .map((event) {
            final data = event.data();
            if (data == null) {
              return Left(ApiException(1000, 'User not found'));
            }
            final List<Map<String, dynamic>> listData = List.from(
              data['giftcardList'],
            );
            final List<GiftcarModel> listGiftcard = listData
                .map((e) => GiftcarModel.fromJson(e))
                .toList();
            return Right(listGiftcard);
          });
    } catch (e) {
      return Stream.value(Left(ApiException(1000, e.toString())));
    }
  }

  @override
  Future<Either<ApiException, List<Map<String, dynamic>>>>
  getAppVersionInfo() async {
    try {
      final response = await _client.get('GeneralInfo');
      logger.info(response);

      if (response != null) {
        return Right(response);
      } else {
        return Left(ApiException(404, 'App version not found'));
      }
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteAccount({
    required String userId,
    required List<String> answers,
  }) async {
    try {
      final response = await _client.set('DeleteAccountRequests', {
        'userId': userId,
        'answers': answers,
      });

      return Right(response);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  Future<Either<ApiException, T>> _executeFirebaseOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return Right(await operation());
    } on FirebaseException catch (e) {
      final httpCode = _mapFirebaseCodeToHttpCode(e.code);
      return Left(ApiException(httpCode, e.message ?? "Error de Firebase"));
    } catch (e) {
      if (e is ApiException) return Left(e);

      return Left(ApiException(1000, e.toString()));
    }
  }

  int _mapFirebaseCodeToHttpCode(String firebaseErrorCode) {
    switch (firebaseErrorCode) {
      case 'permission-denied':
      case 'unauthenticated':
        return 401;
      case 'not-found':
        return 404;
      case 'already-exists':
        return 409;
      case 'invalid-argument':
        return 400;
      case 'too-many-requests':
        return 429;
      case 'unavailable':
        return 503;

      default:
        return 500;
    }
  }

  @override
  Future<Either<ApiException, void>> addManualContact(
    Map<String, dynamic> user,
  ) {
    return _executeFirebaseOperation(() async {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        throw ApiException(401, 'User not authenticated');
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      List<dynamic> manualContacts = [];
      if (userDoc.data() != null &&
          userDoc.data()?.containsKey('manualContacts') == true) {
        manualContacts = List<Map<String, dynamic>>.from(
          userDoc.data()?['manualContacts'] ?? [],
        );
      }

      // Remove any contact with the same phone
      manualContacts.removeWhere(
        (contact) =>
            contact is Map<String, dynamic> &&
            contact['phone'] == user['phone'],
      );

      // Add the new user
      manualContacts.add({'displayName': user['name'], 'phone': user['phone']});

      await _client.update(AppConstants.usersCollection, document: uid, {
        'manualContacts': manualContacts,
        'friendsPhoneList': FieldValue.arrayUnion([user['phone']]),
      });
    });
  }
}
