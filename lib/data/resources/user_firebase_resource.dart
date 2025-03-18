import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserFirebaseResource implements UserRepository {
  UserFirebaseResource({
    required DatabaseHelper client,
    required FirebaseAuth firebaseAuth,
    required FirebaseStorage firebaseStorage,
  })  : _client = client,
        _firebaseAuth = firebaseAuth,
        _firebaseStorage = firebaseStorage;

  final DatabaseHelper _client;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;

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
}
