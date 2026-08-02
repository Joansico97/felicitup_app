part of 'invite_bloc.dart';

enum InviteStatus { initial, loading, success, authRequired, error }

@freezed
abstract class InviteState with _$InviteState {
  const factory InviteState({
    required bool isLoading,
    required InviteStatus status,
    FelicitupModel? currentFelicitup,
    UserModel? currentUser,
    String? errorMessage,
  }) = _InviteState;

  factory InviteState.initial() {
    return const InviteState(
      isLoading: false,
      status: InviteStatus.initial,
    );
  }
}
