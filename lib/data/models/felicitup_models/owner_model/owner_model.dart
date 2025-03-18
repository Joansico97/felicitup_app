import 'package:felicitup_app/helpers/helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'owner_model.freezed.dart';
part 'owner_model.g.dart';

@freezed
class OwnerModel with _$OwnerModel {
  const factory OwnerModel({
    required String id,
    required String name,
    String? userImg,
    @TimestampConverter() required DateTime date,
  }) = _OwnerModel;

  factory OwnerModel.fromJson(Map<String, dynamic> json) => _$OwnerModelFromJson(json);
}
