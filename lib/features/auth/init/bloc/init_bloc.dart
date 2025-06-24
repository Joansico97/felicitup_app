import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'init_event.dart';
part 'init_state.dart';
part 'init_bloc.freezed.dart';

class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc() : super(InitState.initial()) {
    on<InitEvent>(
      (events, emit) =>
          events.map(checkAppStatus: (_) => _checkAppStatus(emit)),
    );
  }

  _checkAppStatus(Emitter<InitState> emit) async {
    try {
      // final response = await _userRepository.getAppVersionInfo();

      // return response.fold(
      //   (error) {
      //     logger.error('Error checking verify status: $error');
      //     emit(const InitState(status: InitEnum.cannotContinue));
      //   },
      //   (success) async {
      //     final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      //     final currentVersion =
      //         '${packageInfo.version}+${packageInfo.buildNumber}';
      //     if (success.first['prodVersion'] != currentVersion) {
      //       emit(const InitState(status: InitEnum.cannotContinue));
      //       logger.error(
      //         'App version mismatch: ${success.first['appVersion']} != $currentVersion',
      //       );
      //     }
      //     emit(const InitState(status: InitEnum.canContinue));
      //   },
      // );
    } catch (e) {
      logger.error('Error checking app status: $e');
      emit(const InitState(status: InitEnum.cannotContinue));
    }
  }
}
