import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/database_helper.dart';

class UserFirebaseResource implements UserRepository {
  UserFirebaseResource({
    required DatabaseHelper client,
  }) : _client = client;

  final DatabaseHelper _client;

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
}
