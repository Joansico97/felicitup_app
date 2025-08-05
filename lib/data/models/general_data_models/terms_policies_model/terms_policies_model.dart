import 'package:freezed_annotation/freezed_annotation.dart';

part 'terms_policies_model.freezed.dart';
part 'terms_policies_model.g.dart';

@freezed
class TermsPoliciesModel with _$TermsPoliciesModel {
  const factory TermsPoliciesModel({
    required String title,
    required String body,
  }) = _TermsPoliciesModel;

  factory TermsPoliciesModel.fromJson(Map<String, dynamic> json) =>
      _$TermsPoliciesModelFromJson(json);
}
