import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'init_event.dart';
part 'init_state.dart';
part 'init_bloc.freezed.dart';

class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(InitState.initial()) {
    on<InitEvent>(
      (events, emit) =>
          events.map(checkAppStatus: (_) => _checkAppStatus(emit)),
    );
  }

  final UserRepository _userRepository;

  _checkAppStatus(Emitter<InitState> emit) async {
    try {
      final response = await _userRepository.getAppVersionInfo();

      return response.fold(
        (error) {
          logger.error('Error checking verify status: $error');
          emit(const InitState(status: InitEnum.cannotContinue));
        },
        (success) async {
          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final currentVersion =
              '${packageInfo.version}+${packageInfo.buildNumber}';
          if (success.first['appVersion'] != currentVersion) {
            emit(const InitState(status: InitEnum.cannotContinue));
            logger.error(
              'App version mismatch: ${success.first['appVersion']} != $currentVersion',
            );
          }
          emit(const InitState(status: InitEnum.canContinue));
        },
      );
    } catch (e) {
      logger.error('Error checking app status: $e');
      emit(const InitState(status: InitEnum.cannotContinue));
    }
  }
}
