import 'package:freezed_annotation/freezed_annotation.dart';

part 'single_chat_model.freezed.dart';
part 'single_chat_model.g.dart';

@freezed
class SingleChatModel with _$SingleChatModel {
  const factory SingleChatModel({
    String? chatId,
    String? userName,
    List<String>? ids,
  }) = _SingleChatModel;

  factory SingleChatModel.fromJson(Map<String, dynamic> json) => _$SingleChatModelFromJson(json);
}
