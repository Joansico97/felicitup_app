import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_felicitup_event.dart';
part 'video_felicitup_state.dart';
part 'video_felicitup_bloc.freezed.dart';

class VideoFelicitupBloc extends Bloc<VideoFelicitupEvent, VideoFelicitupState> {
  VideoFelicitupBloc() : super(VideoFelicitupState.initial()) {
    on<VideoFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (event) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<VideoFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
