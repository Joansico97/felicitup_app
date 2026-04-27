import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felicitup_app/helpers/date_converter.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@freezed
abstract class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    String? id,
    String? message,
    String? sendedBy,
    String? userName,
    String? userImg,
    @TimestampConverter() required DateTime sendedAt,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}
