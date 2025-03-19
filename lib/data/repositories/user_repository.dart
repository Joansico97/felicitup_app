import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';

abstract class UserRepository {
  Future<Either<ApiException, Map<String, dynamic>>> getUserData(String userId);
  Future<Either<ApiException, Map<String, dynamic>>> getUserDataByPhone(String phone);
  Future<Either<ApiException, List<Map<String, dynamic>>>> getListUserData(List<String> usersIds);
  Future<Either<ApiException, List<UserModel>>> getListUserDataByPhone(List<String> phones);
  Future<Either<ApiException, String>> uploadFile(File file, String destination);
  Future<Either<ApiException, void>> sendNotification(
    String userId,
    String title,
    String message,
    String currentChat,
    Map<String, dynamic> data,
  );
  Future<Either<ApiException, UserInvitedInformationModel>> getUserInvitedInformation(String id);
  Future<Either<ApiException, void>> asignCurrentChatId(String id);
  Future<Either<ApiException, void>> updateContacts(List<Map<String, dynamic>> contacts, List<String> phones);
  Future<Either<ApiException, void>> updateMatchList(List<String> ids);
  Future<Either<ApiException, void>> createGiftItem(GiftcarModel item);
  Future<Either<ApiException, void>> editGiftItem(GiftcarModel item);
  Future<Either<ApiException, void>> deleteGiftItem(String id);
}
