part of 'complete_user_data_bloc.dart';

enum CompleteUserDataStatus { none, success, error }

@freezed
abstract class CompleteUserDataState with _$CompleteUserDataState {
  const factory CompleteUserDataState({
    required bool isLoading,
    required CompleteUserDataStatus status,
    String? errorMessage,
  }) = _CompleteUserDataState;

  factory CompleteUserDataState.initial() => const CompleteUserDataState(
    isLoading: false,
    status: CompleteUserDataStatus.none,
  );
}
