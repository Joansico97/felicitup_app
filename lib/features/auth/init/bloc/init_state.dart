part of 'init_bloc.dart';

enum InitEnum { initial, canContinue, cannotContinue }

@freezed
class InitState with _$InitState {
  const factory InitState({required InitEnum status}) = _InitState;

  factory InitState.initial() => const InitState(status: InitEnum.initial);
}
