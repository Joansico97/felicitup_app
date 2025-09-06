import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/felicitup_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_felicitup_event.dart';
part 'video_felicitup_state.dart';
part 'video_felicitup_bloc.freezed.dart';

class VideoFelicitupBloc
    extends Bloc<VideoFelicitupEvent, VideoFelicitupState> {
  VideoFelicitupBloc({required FelicitupRepository felicitupRepository})
    : _felicitupRepository = felicitupRepository,
      super(VideoFelicitupState.initial()) {
    on<VideoFelicitupEvent>(
      (events, emit) => events.map(
        prepareFelicitup: (event) => _prepareFelicitup(emit, event.felicitupId),
        deleteMergedVideo: (event) =>
            _deleteMergedVideo(emit, event.felicitupId),
        mergeVideos: (event) =>
            _mergeVideos(emit, event.felicitupId, event.listVideos),
        startListening: (event) => _startListening(emit, event.felicitupId),
        recivedData: (event) => _recivedData(emit, event.invitedUsers),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<InvitedModel>>>?
  _invitedUsersSubscription;
  final FelicitupRepository _felicitupRepository;

  _prepareFelicitup(
    Emitter<VideoFelicitupState> emit,
    String felicitupId,
  ) async {
    try {
      await _felicitupRepository.prepareFelicitup(felicitupId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al preparar el felicitup'));
    }
  }

  _deleteMergedVideo(
    Emitter<VideoFelicitupState> emit,
    String felicitupId,
  ) async {
    try {
      await _felicitupRepository.deleteMergedVideo(felicitupId);
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Error al eliminar el video combinado'),
      );
    }
  }

  _mergeVideos(
    Emitter<VideoFelicitupState> emit,
    String felicitupId,
    List<String> listVideos,
  ) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 3), () {});
    emit(state.copyWith(isLoading: false, showModal: true));
    try {
      final response = await _felicitupRepository.mergeVideos(
        felicitupId,
        listVideos,
      );
      response.fold((error) {
        logger.error('Error al mezclar videos: $error');
      }, (data) {});
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _startListening(Emitter<VideoFelicitupState> emit, String felicitupId) {
    _invitedUsersSubscription = _felicitupRepository
        .getInvitedStream(felicitupId)
        .listen((either) {
          either.fold((error) {}, (feicitups) {
            add(VideoFelicitupEvent.recivedData(feicitups));
          });
        });
  }

  Future<void> _recivedData(
    Emitter<VideoFelicitupState> emit,
    List<InvitedModel> listUsers,
  ) async {
    emit(state.copyWith(invitedUsers: listUsers));
  }

  @override
  Future<void> close() {
    _invitedUsersSubscription?.cancel();
    return super.close();
  }
}
