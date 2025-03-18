import 'package:freezed_annotation/freezed_annotation.dart';

part 'giftcard_model.freezed.dart';
part 'giftcard_model.g.dart';

@freezed
class GiftcarModel with _$GiftcarModel {
  const factory GiftcarModel({
    String? id,
    String? productName,
    String? productValue,
    String? productDescription,
    List<String>? links,
  }) = _GiftcarModel;

  factory GiftcarModel.fromJson(Map<String, dynamic> json) => _$GiftcarModelFromJson(json);
}
