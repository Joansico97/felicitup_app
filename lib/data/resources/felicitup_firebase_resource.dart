import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/app_constants.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/chat_message_model/chat_message_model.dart';
import 'package:felicitup_app/data/models/felicitup_models/felicitup_model/felicitup_model.dart';
import 'package:felicitup_app/data/models/felicitup_models/invited_model/invited_model.dart';
import 'package:felicitup_app/data/models/user_models/user_models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FelicitupFirebaseResource implements FelicitupRepository {
  FelicitupFirebaseResource({
    required DatabaseHelper databaseHelper,
    required UserRepository userRepository,
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required FirebaseFunctionsHelper firebaseFunctionsHelper,
  })  : _databaseHelper = databaseHelper,
        _userRepository = userRepository,
        _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _firebaseFunctionsHelper = firebaseFunctionsHelper;

  final DatabaseHelper _databaseHelper;
  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctionsHelper _firebaseFunctionsHelper;

  @override
  Future<Either<ApiException, String>> createFelicitup({
    required String id,
    required int boteQuantity,
    required String eventReason,
    required String felicitupMessage,
    required bool hasVideo,
    required bool hasBote,
    required DateTime felicitupDate,
    required List<Map<String, dynamic>> listOwners,
    required List<Map<String, dynamic>> participants,
  }) async {
    try {
      final chatId = _databaseHelper.createId(AppConstants.chatsCollection);
      await _databaseHelper.set(
        AppConstants.chatsCollection,
        document: chatId,
        {
          'messages': [],
        },
      );
      final DateTime limitDate = felicitupDate.subtract(const Duration(days: 1));
      final currentUser = await _userRepository.getUserData(_firebaseAuth.currentUser!.uid);
      currentUser.fold(
        (l) {
          return Left(ApiException(1000, 'Error creating felicitup'));
        },
        (r) async {
          final user = UserModel.fromJson(r);
          final listIds = createListIds(participants: participants, userId: user.id ?? '');
          final listUsersData = createListIdsFromUsers(currentUser: user, participants: participants);
          await _databaseHelper.set(
            AppConstants.feclitiupsCollection,
            document: id,
            {
              'id': id,
              'date': felicitupDate,
              'owner': listOwners,
              'createdBy': user.id,
              'createdAt': DateTime.now(),
              'reason': eventReason,
              'invitedUsers': listIds,
              'invitedUserDetails': listUsersData,
              'hasVideo': hasVideo,
              'hasBote': hasBote,
              'boteQuantity': boteQuantity,
              'limitDate': limitDate,
              'chatId': chatId,
              'message': felicitupMessage,
              'likes': [],
              'status': 'inProgress',
            },
          );
        },
      );

      return Right('Felicitup created successfully');
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, 'Error creating felicitup'));
    }
  }

  @override
  Future<Either<ApiException, FelicitupModel>> getFelicitupById(String felicitupId) async {
    try {
      final data = await _firestore.collection(AppConstants.feclitiupsCollection).doc(felicitupId).get();
      if (data.data() == null) {
        return Left(ApiException(1000, 'Felicitup not found'));
      }
      final felicitup = FelicitupModel.fromJson(data.data()!);
      return Right(felicitup);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> setLike(String felicitupId, String userId) async {
    try {
      final response = await _databaseHelper.get(AppConstants.feclitiupsCollection, document: felicitupId);

      return response.fold(
        (l) {
          return Future.value(Left(ApiException(1000, 'Error setting like')));
        },
        (r) async {
          final felicitup = FelicitupModel.fromJson(r);
          final List<String> likes = List.from(felicitup.likes ?? []);
          if (likes.contains(userId)) {
            likes.remove(userId);
          } else {
            likes.add(userId);
          }
          await _databaseHelper.set(
            AppConstants.feclitiupsCollection,
            document: felicitupId,
            {
              'likes': likes,
            },
          );
          return Right(null);
        },
      );
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> setParticipation(String felicitupId, String newStatus) async {
    try {
      final docRef = _firestore.collection(AppConstants.feclitiupsCollection).doc(felicitupId);
      final felicitup = await docRef.get();
      if (!felicitup.exists) {
        return Left(ApiException(1000, 'Felicitup not found'));
      }
      final userId = _firebaseAuth.currentUser!.uid;

      final felicitupData = felicitup.data() as Map<String, dynamic>; //Cast a Map
      final invitedUserDetails = felicitupData['invitedUserDetails'] as List<dynamic>? ?? [];
      final userIndex = invitedUserDetails.indexWhere((user) => user['id'] == userId);
      if (userIndex == -1) {
        return Left(ApiException(1000, 'User not found'));
      }
      final updatedInvitedUserDetails = List<dynamic>.from(invitedUserDetails);
      updatedInvitedUserDetails[userIndex]['assistanceStatus'] = newStatus;
      await docRef.update({
        'invitedUserDetails': updatedInvitedUserDetails,
      });

      return Right(null);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteParticipant(String felicitupId, String userId) async {
    try {
      final docRef = _firestore.collection(AppConstants.feclitiupsCollection).doc(felicitupId);
      final felicitup = await docRef.get();
      if (!felicitup.exists) {
        return Left(ApiException(1000, 'Felicitup not found'));
      }

      final felicitupData = felicitup.data() as Map<String, dynamic>; //Cast a Map
      final invitedUserDetails = felicitupData['invitedUserDetails'] as List<dynamic>? ?? [];
      final invitedUsers = felicitupData['invitedUsers'] as List<dynamic>? ?? [];
      final userIndex = invitedUserDetails.indexWhere((user) => user['id'] == userId);
      if (userIndex == -1) {
        return Left(ApiException(1000, 'User not found'));
      }
      final updatedInvitedUserDetails = List<dynamic>.from(invitedUserDetails);
      updatedInvitedUserDetails.removeAt(userIndex);
      invitedUsers.remove(userId);

      await docRef.update({
        'invitedUsers': invitedUsers,
        'invitedUserDetails': updatedInvitedUserDetails,
      });

      return Right(null);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updatePaymentData(
    String felicitupId,
    String paymentMethod,
    String paymentStatus,
    DateTime paymentDate,
    String fileUrl,
  ) async {
    try {
      final docId = _databaseHelper.createId(AppConstants.usersInvitedInformationCollection);
      await _databaseHelper.set(
        AppConstants.usersInvitedInformationCollection,
        document: docId,
        {
          'id': docId,
          'userId': _firebaseAuth.currentUser!.uid,
          'photoUrl': fileUrl,
          'paymentMethod': paymentMethod,
          'paymentStatus': paymentStatus,
          'confirmDate': paymentDate,
        },
      );

      final docRef = _firestore.collection(AppConstants.feclitiupsCollection).doc(felicitupId);
      final felicitupDoc = await docRef.get();
      if (!felicitupDoc.exists) {
        return Left(ApiException(1000, 'Felicitup not found'));
      }

      final felicitupData = felicitupDoc.data() as Map<String, dynamic>; //Cast a Map
      final invitedUserDetails = felicitupData['invitedUserDetails'] as List<dynamic>? ?? [];
      final userIndex = invitedUserDetails.indexWhere((user) => user['id'] == _firebaseAuth.currentUser!.uid);

      if (userIndex == -1) {
        throw Exception('Usuario con ID $_firebaseAuth.currentUser!.uid no encontrado en invitedUserDetails.');
      }
      final updatedInvitedUserDetails = List<dynamic>.from(invitedUserDetails);
      updatedInvitedUserDetails[userIndex]['idInformation'] = docId;
      updatedInvitedUserDetails[userIndex]['paid'] = enumToStringPayment(PaymentStatus.waiting);

      await docRef.update({
        'invitedUserDetails': updatedInvitedUserDetails,
      });

      return Right(null);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updateVideoData(String felicitupId, String fileUrl) async {
    try {
      final docRef = _firestore.collection(AppConstants.feclitiupsCollection).doc(felicitupId);
      final felicitup = await docRef.get();
      if (!felicitup.exists) {
        return Left(ApiException(1000, 'Felicitup not found'));
      }
      final userId = _firebaseAuth.currentUser!.uid;

      final felicitupData = felicitup.data() as Map<String, dynamic>; //Cast a Map
      final invitedUserDetails = felicitupData['invitedUserDetails'] as List<dynamic>? ?? [];
      final userIndex = invitedUserDetails.indexWhere((user) => user['id'] == userId);
      if (userIndex == -1) {
        return Left(ApiException(1000, 'User not found'));
      }
      final updatedInvitedUserDetails = List<dynamic>.from(invitedUserDetails);
      updatedInvitedUserDetails[userIndex]['videoData']['videoUrl'] = fileUrl;
      await docRef.update({
        'invitedUserDetails': updatedInvitedUserDetails,
      });

      return Right(null);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> confirmPaymentData(String felicitupId, String userId) async {
    try {
      final docRef = _firestore.collection(AppConstants.feclitiupsCollection).doc(felicitupId);
      final felicitupDoc = await docRef.get();
      if (!felicitupDoc.exists) {
        return Left(ApiException(1000, 'Felicitup not found'));
      }

      final felicitupData = felicitupDoc.data() as Map<String, dynamic>; //Cast a Map
      final invitedUserDetails = felicitupData['invitedUserDetails'] as List<dynamic>? ?? [];
      final userIndex = invitedUserDetails.indexWhere((user) => user['id'] == userId);

      if (userIndex == -1) {
        throw Exception('Usuario con ID $_firebaseAuth.currentUser!.uid no encontrado en invitedUserDetails.');
      }
      final updatedInvitedUserDetails = List<dynamic>.from(invitedUserDetails);
      updatedInvitedUserDetails[userIndex]['paid'] = enumToStringPayment(PaymentStatus.paid);

      await docRef.update({
        'invitedUserDetails': updatedInvitedUserDetails,
      });

      return Right(null);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> mergeVideos(String felicitupId, List<String> listUrlVideos) async {
    try {
      final uid = _firebaseAuth.currentUser!.uid;
      await _firebaseFunctionsHelper.mergeVideos(
        videoUrls: listUrlVideos,
        felicitupId: felicitupId,
        userId: uid,
      );
      return Right(null);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> sendFelicitup(String felicitupId) async {
    try {
      await _firebaseFunctionsHelper.sendManualFelicitup(felicitupId: felicitupId);
      return Right(null);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updateDateFelicitup(String felicitupId, DateTime newDate) async {
    try {
      await _databaseHelper.update(
        AppConstants.feclitiupsCollection,
        document: felicitupId,
        {'date': newDate},
      );
      return Right(null);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Stream<Either<ApiException, List<FelicitupModel>>> streamFelicitups(String userId) {
    try {
      return _firestore
          .collection(AppConstants.feclitiupsCollection)
          .where(
            'invitedUsers',
            arrayContains: userId,
          )
          .snapshots()
          .map((event) {
        final List<Map<String, dynamic>> documents = event.docs.map((e) => e.data()).toList();
        final List<FelicitupModel> listFelicitups = documents.map((e) => FelicitupModel.fromJson(e)).toList();
        return Right(listFelicitups.where((element) => element.status == 'inProgress').toList());
      });
    } catch (e) {
      return Stream.value(Left(ApiException(1000, e.toString())));
    }
  }

  @override
  Stream<Either<ApiException, List<FelicitupModel>>> streamPastFelicitups(String userId) {
    try {
      return _firestore
          .collection(AppConstants.feclitiupsCollection)
          .where(
            'invitedUsers',
            arrayContains: userId,
          )
          .snapshots()
          .map((event) {
        final List<Map<String, dynamic>> documents = event.docs.map((e) => e.data()).toList();
        final List<FelicitupModel> listFelicitups = documents.map((e) => FelicitupModel.fromJson(e)).toList();
        return Right(listFelicitups.where((element) => element.status == 'Finished').toList());
      });
    } catch (e) {
      return Stream.value(Left(ApiException(1000, e.toString())));
    }
  }

  @override
  Stream<Either<ApiException, List<InvitedModel>>> getInvitedStream(String felicitupId) {
    try {
      return _firestore.collection(AppConstants.feclitiupsCollection).doc(felicitupId).snapshots().map((event) {
        final data = event.data();
        if (data == null) {
          return Left(ApiException(1000, 'Felicitup not found'));
        }
        final List<Map<String, dynamic>> invitedUsers = List.from(data['invitedUserDetails']);
        final List<InvitedModel> listInvited = invitedUsers.map((e) => InvitedModel.fromJson(e)).toList();
        return Right(listInvited);
      });
    } catch (e) {
      return Stream.value(Left(ApiException(1000, e.toString())));
    }
  }

  @override
  Stream<Either<ApiException, List<ChatMessageModel>>> getChatMessages(String chatId) {
    try {
      return _firestore.collection(AppConstants.chatsCollection).doc(chatId).snapshots().map((event) {
        final data = event.data();
        if (data == null) {
          return Left(ApiException(1000, 'Felicitup not found'));
        }
        final List<Map<String, dynamic>> messageData = List.from(data['messages']);
        final List<ChatMessageModel> listMessages = messageData.map((e) => ChatMessageModel.fromJson(e)).toList();
        return Right(listMessages);
      });
    } catch (e) {
      return Stream.value(Left(ApiException(1000, e.toString())));
    }
  }
}
