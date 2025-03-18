import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/app_constants.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/felicitup_models/felicitup_model/felicitup_model.dart';
import 'package:felicitup_app/data/models/user_models/user_models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FelicitupFirebaseResource implements FelicitupRepository {
  FelicitupFirebaseResource({
    required DatabaseHelper databaseHelper,
    required UserRepository userRepository,
  })  : _databaseHelper = databaseHelper,
        _userRepository = userRepository;

  final DatabaseHelper _databaseHelper;
  final UserRepository _userRepository;

  @override
  Future<Either<ApiException, String>> createFelicitup({
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
      final felicitupId = _databaseHelper.createId(AppConstants.feclitiupsCollection);
      final chatId = _databaseHelper.createId(AppConstants.chatsCollection);
      await _databaseHelper.set(
        AppConstants.chatsCollection,
        document: chatId,
        {
          'messages': [],
        },
      );
      final DateTime limitDate = felicitupDate.subtract(const Duration(days: 1));
      final currentUser = await _userRepository.getUserData(FirebaseAuth.instance.currentUser!.uid);
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
            document: felicitupId,
            {
              'id': felicitupId,
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

      return Right(felicitupId);
    } catch (e) {
      return Left(ApiException(1000, 'Error creating felicitup'));
    }
  }

  @override
  Future<Either<ApiException, void>> setLike(String felicitupId, String userId) async {
    try {
      final response = await _databaseHelper.get(AppConstants.feclitiupsCollection, document: felicitupId);

      return await response.fold(
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
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }

  @override
  Stream<Either<ApiException, List<FelicitupModel>>> streamFelicitups(String userId) {
    try {
      return FirebaseFirestore.instance
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
      return FirebaseFirestore.instance
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
}
