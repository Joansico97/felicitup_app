import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_past_felicitup_event.dart';
part 'video_past_felicitup_state.dart';
part 'video_past_felicitup_bloc.freezed.dart';

class VideoPastFelicitupBloc extends Bloc<VideoPastFelicitupEvent, VideoPastFelicitupState> {
  VideoPastFelicitupBloc() : super(VideoPastFelicitupState.initial()) {
    on<VideoPastFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        setUrlVideo: (event) => _setUrlVideo(emit, event.url),
      ),
    );
  }

  _changeLoading(Emitter<VideoPastFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _setUrlVideo(Emitter<VideoPastFelicitupState> emit, String url) {
    emit(state.copyWith(currentSelectedVideo: url));
  }
}
