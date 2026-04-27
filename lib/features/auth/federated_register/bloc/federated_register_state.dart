part of 'federated_register_bloc.dart';

enum FederatedRegisterStatus { none, error, success }

@freezed
abstract class FederatedRegisterState with _$FederatedRegisterState {
  const factory FederatedRegisterState({
    required bool isLoading,
    required int currentIndex,
    required FederatedRegisterStatus status,
    String? errorMessage,
    String? name,
    String? lastName,
    String? phone,
    String? hashedPhone,
    String? isoCode,
    String? genre,
    String? verificationId,
    String? userId,
    DateTime? birthDate,
  }) = _FederatedRegisterState;

  factory FederatedRegisterState.initial() => FederatedRegisterState(
    isLoading: false,
    currentIndex: 0,
    status: FederatedRegisterStatus.none,
  );
}
