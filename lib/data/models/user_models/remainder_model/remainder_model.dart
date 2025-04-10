import 'package:felicitup_app/helpers/helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'remainder_model.freezed.dart';
part 'remainder_model.g.dart';

@freezed
class RemainderModel with _$RemainderModel {
  const factory RemainderModel({
    String? birthdayUserId,
    String? birthdayUserName,
    String? friendId,
    String? status,
    String? profileImage,
    @TimestampConverter() DateTime? reminderDate,
    @TimestampConverter() DateTime? targetBirthdayDate,
    @TimestampConverter() DateTime? createdAt,
  }) = _RemainderModel;

  factory RemainderModel.fromJson(Map<String, dynamic> json) => _$RemainderModelFromJson(json);
}
