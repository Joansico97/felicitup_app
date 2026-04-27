import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
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

  Future<void> _checkAppStatus(Emitter<InitState> emit) async {
    if (kIsWeb) return;
  }
}
