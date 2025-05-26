import 'package:felicitup_app/helpers/helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'birthdate_alerts_model.freezed.dart';
part 'birthdate_alerts_model.g.dart';

@freezed
class BirthdateAlertsModel with _$BirthdateAlertsModel {
  const factory BirthdateAlertsModel({
    String? id,
    String? friendId,
    String? friendName,
    String? friendProfilePic,
    @TimestampConverter() DateTime? targetDate,
  }) = _BirthdateAlertsModel;

  factory BirthdateAlertsModel.fromJson(Map<String, dynamic> json) =>
      _$BirthdateAlertsModelFromJson(json);
}
