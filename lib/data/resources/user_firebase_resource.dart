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
  ) async {
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
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, bool>> checkVerifyStatus() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      final isVerified = _firebaseAuth.currentUser?.emailVerified ?? false;
      return Right(isVerified);
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> sendVerifyEmail() async {
    final maxRetries = 3;
    final initialDelay = Duration(seconds: 1);
    for (var i = 0; i < maxRetries; i++) {
      try {
        await _firebaseAuth.currentUser?.sendEmailVerification();
        return Right(null);
      } on FirebaseException catch (e) {
        if (e.code == 'too-many-requests') {
          final delay = initialDelay * (i + 1);
          await Future.delayed(delay);
          continue;
        }
        return Left(
          ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
        );
      } catch (e) {
        return Left(ApiException(1000, e.toString()));
      }
    }
    return Left(
      ApiException(429, 'Too many requests, please try again later.'),
    );
  }

  @override
  Future<Either<ApiException, Map<String, dynamic>>> getUserDataByPhone(
    String phone,
  ) async {
    try {
      final response = await _client.get(AppConstants.usersCollection);
      if (response != null) {
        for (final user in response) {
          if (user['phone'] == phone) {
            return Right(user);
          }
        }
        return Left(ApiException(404, 'User not found'));
      } else {
        return Left(ApiException(404, 'No users found in collection'));
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
      final response = await _client.get(AppConstants.usersCollection);
      if (response != null) {
        final users = response as List<Map<String, dynamic>>;
        final usersData =
            users.where((user) => usersIds.contains(user['id'])).toList();
        return Right(usersData);
      } else {
        return Left(ApiException(404, 'Users not found'));
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
  Future<Either<ApiException, List<UserModel>>> getListUserDataByPhone(
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
      final Set<Map<String, dynamic>> usersSet =
          firebaseUsers.map((e) => e).toSet();
      List<Map<String, dynamic>> matchingUsers =
          usersSet.where((user) {
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
  ) async {
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
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> uploadVideoFile(
    File file,
    String destination,
  ) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      final String videoFileName = "$uid/$destination/${uid}_$destination.mp4";
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
  getUserInvitedInformation(String id) async {
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
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String currentChat,
    required DataMessageModel data,
  }) async {
    try {
      await _firebaseFunctionsHelper.sendNotification(
        userId: userId,
        title: title,
        message: message,
        currentChat: currentChat,
        data: data.toJson(),
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
    } on FirebaseException catch (e) {
      return Left(
        ApiException(int.parse(e.code), e.message ?? "Error de Firebase"),
      );
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
      await _client.update(AppConstants.usersCollection, document: uid, {
        'currentChat': id,
      });
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
  Future<Either<ApiException, void>> updateUserInfo(UserModel user) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      final userDocRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userDocRef);

        if (!userDoc.exists) {
          throw ApiException(404, 'User not found');
        }

        transaction.update(userDocRef, {
          'name': user.firstName,
          'lastName': user.lastName,
          'phone': user.phone,
          'isoCode': user.isoCode,
          'fullName': '${user.firstName} ${user.lastName}',
        });
      });
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
  Future<Either<ApiException, void>> updateContacts(
    List<Map<String, dynamic>> contacts,
    List<String> phones,
  ) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _client.update(AppConstants.usersCollection, document: uid, {
        'friendList': contacts,
        'friendsPhoneList': phones,
      });
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
  Future<Either<ApiException, void>> updateMatchList(List<String> ids) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _client.update(AppConstants.usersCollection, document: uid, {
        'matchList': ids,
      });
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
  Future<Either<ApiException, void>> updateUserImageFromFile(File file) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }

      final response = await uploadFile(file, 'profile');

      response.fold((l) => Left(l), (url) async {
        await _client.update(AppConstants.usersCollection, document: uid, {
          'userImg': url,
        });
      });

      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updateUserImageFromUrl(String url) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _client.update(AppConstants.usersCollection, document: uid, {
        'userImg': url,
      });
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

        final userData = userDoc.data();
        if (userData == null) {
          return Left(
            ApiException(404, "Error al obtener la información del usuario"),
          );
        }
        final giftcardList = userData['giftcardList'] as List<dynamic>? ?? [];

        final indexToRemove = giftcardList.indexWhere((item) {
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

        final updatedList = List<dynamic>.from(giftcardList);
        final itemToRemove = updatedList.removeAt(indexToRemove);

        transaction.update(userDocRef, {
          'giftcardList': FieldValue.arrayRemove([itemToRemove]),
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
    required String itemId, // ID del item a editar
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
        final userDoc = await transaction.get(
          userDocRef,
        ); //Obtener documento actual

        if (!userDoc.exists) {
          return Left(
            ApiException(404, "Usuario no encontrado"),
          ); // 404 Not Found
        }

        final userData = userDoc.data();
        if (userData == null) {
          return Left(
            ApiException(404, "No se pudieron obtener los datos del usuario."),
          );
        }

        final giftcardList =
            userData['giftcardList'] as List<dynamic>? ??
            []; //Obtener lista, o lista vacía

        final itemIndex = giftcardList.indexWhere((item) {
          if (item is Map<String, dynamic>) {
            return item['id'] == itemId; //Compara con el id
          }
          return false;
        });

        if (itemIndex == -1) {
          return Left(ApiException(404, "Ítem no encontrado"));
        }

        //Crea una copia de la lista.
        final updatedList = List<dynamic>.from(giftcardList);

        // 1.  Crea un mapa con los *nuevos* valores, solo si se proporcionaron.
        final Map<String, dynamic> updatedItem = Map.from(
          updatedList[itemIndex] as Map<String, dynamic>,
        ); //Crea una copia del elemento a actualizar

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

        //Reemplaza en la lista el item
        updatedList[itemIndex] = updatedItem;

        // 2.  Actualiza el documento *usando la lista modificada*.
        transaction.update(userDocRef, {'giftcardList': updatedList});

        return Right(null); // Éxito
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
  Future<Either<ApiException, void>> setFCMToken(String token) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _client.update(AppConstants.usersCollection, document: uid, {
        'fcmToken': token,
      });
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
    DateTime birthDate,
  ) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(ApiException(401, 'User not authenticated'));
      }
      await _client.update(AppConstants.usersCollection, document: uid, {
        'name': name,
        'lastName': lastName,
        'phone': phone,
        'isoCode': isoCode,
        'genre': genre,
        'birthDate': birthDate,
      });
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
            final List<GiftcarModel> listGiftcard =
                listData.map((e) => GiftcarModel.fromJson(e)).toList();
            return Right(listGiftcard);
          });
    } catch (e) {
      return Stream.value(Left(ApiException(1000, e.toString())));
    }
  }
}
