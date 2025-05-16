import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';

abstract class UserRepository {
  Future<Either<ApiException, Map<String, dynamic>>> getUserData(String userId);
  Future<Either<ApiException, bool>> checkVerifyStatus();
  Future<Either<ApiException, void>> sendVerifyEmail();
  Future<Either<ApiException, Map<String, dynamic>>> getUserDataByPhone(
    String phone,
  );
  Future<Either<ApiException, List<Map<String, dynamic>>>> getListUserData(
    List<String> usersIds,
  );
  Future<Either<ApiException, List<UserModel>>> getListUserDataByPhone(
    List<String> phones,
  );
  Future<Either<ApiException, String>> uploadFile(
    File file,
    String destination,
  );
  Future<Either<ApiException, String>> uploadVideoFile(
    File file,
    String destination,
  );
  Future<Either<ApiException, void>> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String currentChat,
    required DataMessageModel data,
  });
  Future<Either<ApiException, void>> sendNotificationToListUsers(
    List<String> ids,
    String title,
    String message,
    String currentChat,
    DataMessageModel data,
  );
  Future<Either<ApiException, UserInvitedInformationModel>>
  getUserInvitedInformation(String id);
  Future<Either<ApiException, void>> asignCurrentChatId(String id);
  Future<Either<ApiException, void>> updateContacts(
    List<Map<String, dynamic>> contacts,
    List<String> phones,
  );
  Future<Either<ApiException, void>> updateMatchList(List<String> ids);
  Future<Either<ApiException, void>> updateUserImageFromFile(File file);
  Future<Either<ApiException, void>> updateUserImageFromUrl(String url);
  Future<Either<ApiException, void>> updateUserInfo(UserModel user);
  Future<Either<ApiException, void>> createGiftItem(GiftcarModel item);
  Future<Either<ApiException, void>> editGiftItem({
    required String itemId,
    String? newProductName,
    String? newProductValue,
    String? newProductDescription,
    List<String>? newLinks,
  });
  Future<Either<ApiException, void>> deleteGiftItem(String id);
  Future<Either<ApiException, void>> deleteReminder(String id);
  Future<Either<ApiException, void>> setFCMToken(String token);
  Future<Either<ApiException, void>> syncNotifications(
    PushMessageModel notification,
  );
  Future<Either<ApiException, void>> deleteNotification(String notificationId);
  Future<Either<ApiException, void>> setInitialUserInfo(UserModel user);

  Future<Either<ApiException, void>> setUserInfoRemaining(
    String name,
    String lastName,
    String phone,
    String isoCode,
    String genre,
    DateTime birthDate,
  );
  Future<Either<ApiException, void>> setFederatedData({
    required String firstName,
    required String lastName,
    required String genre,
    required DateTime birthDate,
  });
  Future<Either<ApiException, void>> setUserPhone(
    String phone,
    String isoCode,
    String userId,
  );
  Stream<Either<ApiException, List<GiftcarModel>>> getGiftcardListStream();
}
