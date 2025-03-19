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
    DataMessageModel? data,
  }) = _PushMessageModel;

  factory PushMessageModel.fromJson(Map<String, dynamic> json) => _$PushMessageModelFromJson(json);
}

@freezed
class DataMessageModel with _$DataMessageModel {
  const factory DataMessageModel({
    String? felicitupId,
    String? chatId,
    String? isAssistance,
    String? isPast,
    String? singleChatId,
    String? name,
    List<String>? ids,
  }) = _DataMessageModel;

  factory DataMessageModel.fromJson(Map<String, dynamic> json) => _$DataMessageModelFromJson(json);
}
