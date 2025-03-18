import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_message_model.freezed.dart';
part 'push_message_model.g.dart';

@freezed
class PushMessageModel with _$PushMessageModel {
  const factory PushMessageModel({
    required String messageId,
    required String title,
    required String body,
    required DateTime sentDate,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) = _PushMessageModel;

  factory PushMessageModel.fromJson(Map<String, dynamic> json) => _$PushMessageModelFromJson(json);
}
