import 'package:freezed_annotation/freezed_annotation.dart';

part 'birthdate_alerts_model.freezed.dart';
part 'birthdate_alerts_model.g.dart';

@freezed
class BirthdateAlertsModel with _$BirthdateAlertsModel {
  const factory BirthdateAlertsModel({
    String? friendId,
    String? friendName,
  }) = _BirthdateAlertsModel;

  factory BirthdateAlertsModel.fromJson(Map<String, dynamic> json) => _$BirthdateAlertsModelFromJson(json);
}
