import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';

abstract class UserRepository {
  Future<Either<ApiException, Map<String, dynamic>>> getUserData(String userId);
  Future<Either<ApiException, List<Map<String, dynamic>>>> getListUserData(List<String> usersIds);
}
