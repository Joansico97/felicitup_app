import 'package:freezed_annotation/freezed_annotation.dart';

part 'invited_model.freezed.dart';
part 'invited_model.g.dart';

enum AssistanceStatus {
  pending,
  accepted,
  rejected,
}

enum PaymentStatus {
  pending,
  waiting,
  paid,
}

String enumToStringAssistance(AssistanceStatus enumValue) {
  switch (enumValue) {
    case AssistanceStatus.pending:
      return 'pending';
    case AssistanceStatus.accepted:
      return 'accepted';
    case AssistanceStatus.rejected:
      return 'rejected';
  }
}

String enumToStringPayment(PaymentStatus enumValue) {
  switch (enumValue) {
    case PaymentStatus.pending:
      return 'pending';
    case PaymentStatus.waiting:
      return 'waiting';
    case PaymentStatus.paid:
      return 'paid';
  }
}

@Freezed(makeCollectionsUnmodifiable: false)
class InvitedModel with _$InvitedModel {
  const factory InvitedModel({
    String? id,
    String? name,
    String? userImage,
    String? assistanceStatus,
    String? paid,
    VideoDataModel? videoData,
    String? idInformation,
  }) = _InvitedModel;

  factory InvitedModel.fromJson(Map<String, dynamic> json) => _$InvitedModelFromJson(json);
}

@freezed
class VideoDataModel with _$VideoDataModel {
  const factory VideoDataModel({
    String? videoUrl,
    String? videoThumbnail,
  }) = _VideoDataModel;

  factory VideoDataModel.fromJson(Map<String, dynamic> json) => _$VideoDataModelFromJson(json);
}
