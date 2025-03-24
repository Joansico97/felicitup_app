import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_message_model.freezed.dart';
part 'push_message_model.g.dart';

enum PushMessageType { felicitup, chat, singleChat, payment, participation, video, past }

String enumToPushMessageType(PushMessageType enumValue) {
  switch (enumValue) {
    case PushMessageType.felicitup:
      return 'felicitup';
    case PushMessageType.chat:
      return 'chat';
    case PushMessageType.singleChat:
      return 'singleChat';
    case PushMessageType.payment:
      return 'payment';
    case PushMessageType.participation:
      return 'participation';
    case PushMessageType.video:
      return 'video';
    case PushMessageType.past:
      return 'past';
  }
}

PushMessageType pushMessageTypeToEnum(String value) {
  switch (value) {
    case 'felicitup':
      return PushMessageType.felicitup;
    case 'chat':
      return PushMessageType.chat;
    case 'singleChat':
      return PushMessageType.singleChat;
    case 'payment':
      return PushMessageType.payment;
    case 'participation':
      return PushMessageType.participation;
    case 'video':
      return PushMessageType.video;
    case 'past':
      return PushMessageType.past;
    default:
      throw Exception('Unknown PushMessageType: $value');
  }
}

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
    String? type,
    String? felicitupId,
    String? chatId,
    String? name,
    // List<String>? ids,
  }) = _DataMessageModel;

  factory DataMessageModel.fromJson(Map<String, dynamic> json) => _$DataMessageModelFromJson(json);
}
