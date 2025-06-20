import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';

part 'video_editor_event.dart';
part 'video_editor_state.dart';
part 'video_editor_bloc.freezed.dart';

class VideoEditorBloc extends Bloc<VideoEditorEvent, VideoEditorState> {
  VideoEditorBloc({
    required UserRepository userRepository,
    required FelicitupRepository felicitupRepository,
    required FirebaseAuth firebaseAuth,
    required FirebaseFunctionsHelper firebaseFunctionsHelper,
  }) : _userRepository = userRepository,
       _felicitupRepository = felicitupRepository,
       _firebaseAuth = firebaseAuth,
       _firebaseFunctionsHelper = firebaseFunctionsHelper,
       super(VideoEditorState.initial()) {
    on<VideoEditorEvent>(
      (events, emit) => events.map(
        changeLoading: (event) => _changeLoading(emit),
        setUrlVideo: (event) => _setUrlVideo(emit, event.url),
        getFelicitupInfo: (event) => _getFelicitupInfo(emit, event.felicitupId),
        uploadUserVideo:
            (event) => _uploadUserVideo(emit, event.felicitupId, event.file),
        updateParticipantInfo:
            (event) => _updateParticipantInfo(event.felicitupId, event.url),
        initializeVideoController:
            (event) => _initializeVideoController(emit, event.url),
        disposeVideoController: (event) => _disposeVideoController(emit),
        generateThumbnail: (event) => _generateThumbnail(event.filePath),
        setDuraton: (event) => _setDuraton(emit, event.duration),
        setPosition: (event) => _setPosition(emit, event.position),
        changeFullScreen: (event) => _changeFullScreen(emit),
        reportUserVideo:
            (event) => _reportUserVideo(
              emit,
              event.felicitupId,
              event.userId,
              event.videoUrl,
            ),
      ),
    );
  }

  final UserRepository _userRepository;
  final FelicitupRepository _felicitupRepository;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctionsHelper _firebaseFunctionsHelper;

  _changeLoading(Emitter<VideoEditorState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _setUrlVideo(Emitter<VideoEditorState> emit, String url) {
    add(VideoEditorEvent.initializeVideoController(url));
    emit(state.copyWith(currentSelectedVideo: url));
  }

  _getFelicitupInfo(Emitter<VideoEditorState> emit, String felicitupId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _felicitupRepository.getFelicitupById(felicitupId);
      result.fold(
        (error) => logger.error('Error fetching Felicitup info: $error'),
        (felicitup) {
          emit(state.copyWith(isLoading: false, currentFelicitup: felicitup));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _uploadUserVideo(
    Emitter<VideoEditorState> emit,
    String felicitupId,
    File file,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _userRepository.uploadVideoFile(file, 'videos');
      return result.fold(
        (error) => logger.error('Error uploading video: $error'),
        (url) {
          add(VideoEditorEvent.updateParticipantInfo(felicitupId, url));
          add(VideoEditorEvent.initializeVideoController(url));
          add(VideoEditorEvent.getFelicitupInfo(felicitupId));
          // add(VideoEditorEvent.generateThumbnail(extractFilePathFromFirebaseStorageUrl(url)));
          emit(state.copyWith(isLoading: false, currentSelectedVideo: url));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _initializeVideoController(Emitter<VideoEditorState> emit, String url) async {
    emit(state.copyWith(isLoading: true));
    try {
      final videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await videoPlayerController.initialize().then((_) {
        videoPlayerController.play();
        videoPlayerController.addListener(() {
          if (videoPlayerController.value.isInitialized) {
            add(
              VideoEditorEvent.setDuraton(videoPlayerController.value.duration),
            );
            add(
              VideoEditorEvent.setPosition(
                videoPlayerController.value.position,
              ),
            );
          }
        });
      });
      emit(
        state.copyWith(
          isLoading: false,
          videoPlayerController: videoPlayerController,
          currentSelectedVideo: url,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _disposeVideoController(Emitter<VideoEditorState> emit) {
    emit(state.copyWith(isLoading: true));
    try {
      state.videoPlayerController?.dispose();
      emit(state.copyWith(isLoading: false, videoPlayerController: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _generateThumbnail(String filePath) async {
    try {
      await _firebaseFunctionsHelper.generateThumbnail(
        filePath: filePath,
        userId: _firebaseAuth.currentUser!.uid,
      );
    } catch (e) {
      logger.error('Error generating thumbnail: $e');
    }
  }

  _updateParticipantInfo(String felicitupId, String url) async {
    try {
      await _felicitupRepository.updateVideoData(felicitupId, url);
    } catch (e) {
      logger.error('Error updating participant info: $e');
    }
  }

  _setDuraton(Emitter<VideoEditorState> emit, Duration duration) {
    emit(state.copyWith(duration: duration));
  }

  _setPosition(Emitter<VideoEditorState> emit, Duration position) {
    emit(state.copyWith(position: position));
  }

  _changeFullScreen(Emitter<VideoEditorState> emit) {
    emit(state.copyWith(isFullScreen: !state.isFullScreen));
  }

  _reportUserVideo(
    Emitter<VideoEditorState> emit,
    String felicitupId,
    String userId,
    String videoUrl,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _felicitupRepository.reportUserVideo(
        felicitupId,
        userId,
        videoUrl,
      );
      result.fold((error) => logger.error('Error reporting video: $error'), (
        _,
      ) {
        emit(state.copyWith(isLoading: false));
        // Optionally, you can show a success message or perform other actions
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      logger.error('Error in reportUserVideo: $e');
    }
  }

  @override
  Future<void> close() {
    state.videoPlayerController?.dispose();
    return super.close();
  }
}
