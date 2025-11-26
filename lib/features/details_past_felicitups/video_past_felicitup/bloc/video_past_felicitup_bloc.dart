import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_past_felicitup_event.dart';
part 'video_past_felicitup_state.dart';
part 'video_past_felicitup_bloc.freezed.dart';

class VideoPastFelicitupBloc
    extends Bloc<VideoPastFelicitupEvent, VideoPastFelicitupState> {
  VideoPastFelicitupBloc() : super(VideoPastFelicitupState.initial()) {
    on<VideoPastFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => emit(state.copyWith(isLoading: !state.isLoading)),
        setUrlVideo: (event) =>
            emit(state.copyWith(currentSelectedVideo: event.url)),
      ),
    );
  }
}
