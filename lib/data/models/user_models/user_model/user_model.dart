import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? isoCode,
    String? phone,
    String? userImg,
    String? fcmToken,
    String? currentChat,
    int? birthMonth,
    int? birthDay,
    List<ContactModel>? friendList,
    List<BirthdateAlertsModel>? birthdateAlerts,
    List<RemainderModel>? remainders,
    List<String>? matchList,
    List<String>? friendsPhoneList,
    List<GiftcarModel>? giftcardList,
    List<PushMessageModel>? notifications,
    List<SingleChatModel>? singleChats,
    @TimestampConverter() DateTime? birthDate,
    @TimestampConverter() DateTime? registerDate,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
