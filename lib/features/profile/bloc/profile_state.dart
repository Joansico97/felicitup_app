part of 'profile_bloc.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    required bool isLoading,
  }) = _ProfileState;

  factory ProfileState.initial() => const ProfileState(
        isLoading: false,
      );
}
