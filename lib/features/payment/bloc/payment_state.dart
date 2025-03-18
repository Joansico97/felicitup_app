part of 'payment_bloc.dart';

enum UpdateStatus { initial, loading, success, error }

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState({
    required bool isLoading,
    required String errorMessage,
    required UpdateStatus updateStatus,
    String? fileUrl,
    UserInvitedInformationModel? userInvitedInformationModel,
  }) = _PaymentState;

  factory PaymentState.initial() => PaymentState(
        isLoading: false,
        errorMessage: '',
        updateStatus: UpdateStatus.initial,
      );
}
