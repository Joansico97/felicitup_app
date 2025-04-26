import 'package:freezed_annotation/freezed_annotation.dart';

part 'birthdate_alerts_model.freezed.dart';
part 'birthdate_alerts_model.g.dart';

@freezed
class BirthdateAlertsModel with _$BirthdateAlertsModel {
  const factory BirthdateAlertsModel({
    String? id,
    int? daysOffset,
    String? friendId,
    String? friendName,
    String? friendProfilePic,
    String? targetDate,
  }) = _BirthdateAlertsModel;

  factory BirthdateAlertsModel.fromJson(Map<String, dynamic> json) =>
      _$BirthdateAlertsModelFromJson(json);
}
