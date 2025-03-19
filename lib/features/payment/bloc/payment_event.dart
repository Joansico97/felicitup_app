part of 'payment_bloc.dart';

@freezed
class PaymentEvent with _$PaymentEvent {
  const factory PaymentEvent.changeLoadign() = _changeLoading;
  const factory PaymentEvent.getUserInformation(String id) = _getUserInformation;
  const factory PaymentEvent.uploadPaymenFile(File file) = _uploadPaymenFile;
  const factory PaymentEvent.confirmPaymentInfo(String felicitupId, String userId) = _confirmPaymentInfo;
  const factory PaymentEvent.sendNotification(
    String userId,
    String title,
    String message,
    String currentChat,
    Map<String, dynamic> data,
  ) = _sendNotification;
  const factory PaymentEvent.updatePaymentInfo(
    String felicitupId,
    String paymentMethod,
    String paymentStatus,
    DateTime paymentDate,
    String file,
  ) = _updatePaymentInfo;
}
