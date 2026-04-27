part of 'init_bloc.dart';

@freezed
abstract class InitEvent with _$InitEvent {
  const factory InitEvent.checkAppStatus() = _checkAppStatus;
}
