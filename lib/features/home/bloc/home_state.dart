part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required bool isLoading,
    required bool create,
    required bool showButton,
  }) = _HomeState;

  factory HomeState.initial() => HomeState(
        isLoading: false,
        create: false,
        showButton: true,
      );
}
