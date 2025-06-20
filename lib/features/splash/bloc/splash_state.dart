part of 'splash_bloc.dart';

@freezed
class SplashState with _$SplashState {
  const factory SplashState({required bool isLoading}) = _SplashState;

  factory SplashState.initial() => SplashState(isLoading: true);
}
