import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
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
        changeLoading: (event) =>
            emit(state.copyWith(isLoading: !state.isLoading)),
        setUrlVideo: (event) => _setUrlVideo(emit, event.url),
        getFelicitupInfo: (event) => _getFelicitupInfo(emit, event.felicitupId),
        uploadUserVideo: (event) => _uploadUserVideo(
          emit,
          event.felicitupId,
          event.file,
          event.userId,
          event.userName,
          event.felicitupCreatorId,
        ),
        updateParticipantInfo: (event) =>
            _updateParticipantInfo(event.felicitupId, event.url),
        initializeVideoController: (event) =>
            _initializeVideoController(emit, event.url),
        disposeVideoController: (event) => _disposeVideoController(emit),
        generateThumbnail: (event) => _generateThumbnail(event.filePath),
        setDuraton: (event) => _setDuraton(emit, event.duration),
        setPosition: (event) => _setPosition(emit, event.position),
        changeFullScreen: (event) => _changeFullScreen(emit),
        normalizeVideo: (event) => _normalizeVideo(
          emit,
          url: event.url,
          userId: event.userId,
          felicitupId: event.felicitupId,
        ),
        reportUserVideo: (event) => _reportUserVideo(
          emit,
          event.felicitupId,
          event.userId,
          event.videoUrl,
        ),
        sendNotification: (event) => _sendNotification(
          emit,
          event.userId,
          event.userName,
          event.felicitupId,
        ),
      ),
    );
  }

  final UserRepository _userRepository;
  final FelicitupRepository _felicitupRepository;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctionsHelper _firebaseFunctionsHelper;

  void _setUrlVideo(Emitter<VideoEditorState> emit, String url) {
    add(VideoEditorEvent.initializeVideoController(url));
    emit(state.copyWith(currentSelectedVideo: url));
  }

  Future<void> _getFelicitupInfo(
    Emitter<VideoEditorState> emit,
    String felicitupId,
  ) async {
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

  Future<void> _normalizeVideo(
    Emitter<VideoEditorState> emit, {
    required String url,
    required String userId,
    required String felicitupId,
  }) async {
    try {
      await _firebaseFunctionsHelper.normalizeSingleVideo(
        videoUrl: url,
        felicitupId: felicitupId,
        userId: userId,
      );
    } catch (e) {
      logger.error('Error normalizing video: $e');
    }
  }

  Future<void> _uploadUserVideo(
    Emitter<VideoEditorState> emit,
    String felicitupId,
    File file,
    String userId,
    String userName,
    String felicitupCreatorId,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final uniqueId = const Uuid().v4();
      final result = await _userRepository.uploadVideoFile(
        file,
        'videos',
        uniqueId,
      );
      return result.fold(
        (error) => logger.error('Error uploading video: $error'),
        (url) {
          final correctUrl = extractFilePathFromFirebaseStorageUrl(url);
          add(
            VideoEditorEvent.normalizeVideo(
              url: correctUrl,
              userId: userId,
              felicitupId: felicitupId,
            ),
          );
          add(VideoEditorEvent.updateParticipantInfo(felicitupId, url));
          add(VideoEditorEvent.initializeVideoController(url));
          add(VideoEditorEvent.getFelicitupInfo(felicitupId));
          add(
            VideoEditorEvent.sendNotification(
              felicitupCreatorId,
              userName,
              felicitupId,
            ),
          );
          emit(state.copyWith(isLoading: false, currentSelectedVideo: url));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _initializeVideoController(
    Emitter<VideoEditorState> emit,
    String url,
  ) async {
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

  void _disposeVideoController(Emitter<VideoEditorState> emit) {
    emit(state.copyWith(isLoading: true));
    try {
      state.videoPlayerController?.dispose();
      emit(state.copyWith(isLoading: false, videoPlayerController: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _generateThumbnail(String filePath) async {
    try {
      await _firebaseFunctionsHelper.generateThumbnail(
        filePath: filePath,
        userId: _firebaseAuth.currentUser!.uid,
      );
    } catch (e) {
      logger.error('Error generating thumbnail: $e');
    }
  }

  Future<void> _updateParticipantInfo(String felicitupId, String url) async {
    try {
      await _felicitupRepository.updateVideoData(felicitupId, url);
    } catch (e) {
      logger.error('Error updating participant info: $e');
    }
  }

  void _setDuraton(Emitter<VideoEditorState> emit, Duration duration) {
    emit(state.copyWith(duration: duration));
  }

  void _setPosition(Emitter<VideoEditorState> emit, Duration position) {
    emit(state.copyWith(position: position));
  }

  void _changeFullScreen(Emitter<VideoEditorState> emit) {
    emit(state.copyWith(isFullScreen: !state.isFullScreen));
  }

  Future<void> _reportUserVideo(
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

  Future<void> _sendNotification(
    Emitter<VideoEditorState> emit,
    String userId,
    String userName,
    String felicitupId,
  ) async {
    try {
      await _userRepository.sendNotification(
        userId: userId,
        title: 'Nuevo vídeo',
        message: '$userName ha grabado un nuevo vídeo',
        currentChat: '',
        data: DataMessageModel(
          type: enumToPushMessageType(PushMessageType.chat),
          felicitupId: felicitupId,
          chatId: '',
          name: '',
          friendId: '',
          userImage: '',
        ),
      );
    } catch (e) {
      logger.error(e.toString());
    }
  }
}
