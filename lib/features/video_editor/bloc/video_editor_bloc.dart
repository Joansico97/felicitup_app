import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_editor_event.dart';
part 'video_editor_state.dart';
part 'video_editor_bloc.freezed.dart';

class VideoEditorBloc extends Bloc<VideoEditorEvent, VideoEditorState> {
  VideoEditorBloc({
    required UserRepository userRepository,
    required FelicitupRepository felicitupRepository,
  })  : _userRepository = userRepository,
        _felicitupRepository = felicitupRepository,
        super(VideoEditorState.initial()) {
    on<VideoEditorEvent>(
      (events, emit) => events.map(
        changeLoading: (event) => _changeLoading(emit),
        setUrlVideo: (event) => _setUrlVideo(emit, event.url),
        uploadUserVideo: (event) => _uploadUserVideo(emit, event.felicitupId, event.file),
        updateParticipantInfo: (event) => _updateParticipantInfo(event.felicitupId, event.url),
      ),
    );
  }

  final UserRepository _userRepository;
  final FelicitupRepository _felicitupRepository;

  _changeLoading(Emitter<VideoEditorState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _setUrlVideo(Emitter<VideoEditorState> emit, String url) {
    emit(state.copyWith(currentSelectedVideo: url));
  }

  _uploadUserVideo(Emitter<VideoEditorState> emit, String felicitupId, File file) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _userRepository.uploadVideoFile(file, 'videos');
      result.fold(
        (error) => logger.error('Error uploading video: $error'),
        (url) {
          add(VideoEditorEvent.updateParticipantInfo(felicitupId, url));
          emit(state.copyWith(isLoading: false, currentSelectedVideo: url));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _updateParticipantInfo(String felicitupId, String url) async {
    try {
      await _felicitupRepository.updateVideoData(felicitupId, url);
    } catch (e) {
      logger.error('Error updating participant info: $e');
    }
  }
}
