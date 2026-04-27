part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, error, contactsUpdateSuccess }

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    required bool isLoading,
    required bool create,
    required bool showButton,
    required HomeStatus status,
  }) = _HomeState;

  factory HomeState.initial() => HomeState(
    isLoading: false,
    create: false,
    showButton: true,
    status: HomeStatus.initial,
  );
}
