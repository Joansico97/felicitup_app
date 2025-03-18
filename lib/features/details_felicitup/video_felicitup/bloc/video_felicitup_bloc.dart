import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/felicitup_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_felicitup_event.dart';
part 'video_felicitup_state.dart';
part 'video_felicitup_bloc.freezed.dart';

class VideoFelicitupBloc extends Bloc<VideoFelicitupEvent, VideoFelicitupState> {
  VideoFelicitupBloc({
    required FelicitupRepository felicitupRepository,
  })  : _felicitupRepository = felicitupRepository,
        super(VideoFelicitupState.initial()) {
    on<VideoFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (event) => _changeLoading(emit),
        startListening: (event) => _startListening(emit, event.felicitupId),
        recivedData: (event) => _recivedData(emit, event.invitedUsers),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<InvitedModel>>>? _invitedUsersSubscription;
  final FelicitupRepository _felicitupRepository;

  _changeLoading(Emitter<VideoFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _startListening(Emitter<VideoFelicitupState> emit, String felicitupId) {
    _invitedUsersSubscription = _felicitupRepository.getInvitedStream(felicitupId).listen((either) {
      either.fold(
        (error) {},
        (feicitups) {
          add(VideoFelicitupEvent.recivedData(feicitups));
        },
      );
    });
  }

  Future<void> _recivedData(Emitter<VideoFelicitupState> emit, List<InvitedModel> listUsers) async {
    emit(state.copyWith(invitedUsers: listUsers));
  }

  @override
  Future<void> close() {
    _invitedUsersSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
