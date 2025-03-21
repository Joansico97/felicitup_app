part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, success, error }

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    required bool isLoading,
    required ProfileStatus status,
  }) = _ProfileState;

  factory ProfileState.initial() => const ProfileState(
        isLoading: false,
        status: ProfileStatus.initial,
      );
}
