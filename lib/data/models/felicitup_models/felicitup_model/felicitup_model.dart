import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'felicitup_model.freezed.dart';
part 'felicitup_model.g.dart';

@freezed
class FelicitupModel with _$FelicitupModel {
  const factory FelicitupModel({
    required String id,
    required String createdBy,
    @TimestampConverter() required DateTime createdAt,
    required String reason,
    String? finalVideoUrl,
    @TimestampConverter() required DateTime date,
    required bool hasBote,
    required bool hasVideo,
    required List<String> invitedUsers,
    required List<InvitedModel> invitedUserDetails,
    required List<OwnerModel> owner,
    required int boteQuantity,
    String? message,
    String? status,
    String? thumbnailUrl,
    List<String>? likes,
    @TimestampConverter() required DateTime limitDate,
    required String chatId,
  }) = _FelicitupModel;

  factory FelicitupModel.fromJson(Map<String, dynamic> json) => _$FelicitupModelFromJson(json);
}
