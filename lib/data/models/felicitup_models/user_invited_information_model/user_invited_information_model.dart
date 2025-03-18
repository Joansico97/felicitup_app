import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_invited_information_model.freezed.dart';
part 'user_invited_information_model.g.dart';

@freezed
class UserInvitedInformationModel with _$UserInvitedInformationModel {
  const factory UserInvitedInformationModel({
    required String id,
    required String userId,
    String? photoUrl,
    required String paymentMethod,
    @TimestampConverter() DateTime? paymentDate,
    @TimestampConverter() DateTime? confirmDate,
  }) = _UserInvitedInformationModel;

  factory UserInvitedInformationModel.fromJson(Map<String, dynamic> json) =>
      _$UserInvitedInformationModelFromJson(json);
}
