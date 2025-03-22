part of 'federated_register_bloc.dart';

@freezed
class FederatedRegisterState with _$FederatedRegisterState {
  const factory FederatedRegisterState({
    required bool isLoading,
    required int currentIndex,
    String? name,
    String? lastName,
    String? phone,
    String? isoCode,
    String? genre,
    DateTime? birthDate,
  }) = _FederatedRegisterState;

  factory FederatedRegisterState.initial() => FederatedRegisterState(
        isLoading: false,
        currentIndex: 0,
      );
}
