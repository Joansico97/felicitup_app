import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_editor_event.dart';
part 'video_editor_state.dart';
part 'video_editor_bloc.freezed.dart';

class VideoEditorBloc extends Bloc<VideoEditorEvent, VideoEditorState> {
  VideoEditorBloc() : super(VideoEditorState.initial()) {
    on<VideoEditorEvent>(
      (events, emit) => events.map(
        changeLoading: (event) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<VideoEditorState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
