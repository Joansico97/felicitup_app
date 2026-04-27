import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/repositories/repositories.dart';

part 'people_past_felicitup_event.dart';
part 'people_past_felicitup_state.dart';
part 'people_past_felicitup_bloc.freezed.dart';

class PeoplePastFelicitupBloc
    extends Bloc<PeoplePastFelicitupEvent, PeoplePastFelicitupState> {
  PeoplePastFelicitupBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
  }) : _felicitupRepository = felicitupRepository,
       _userRepository = userRepository,
       super(PeoplePastFelicitupState.initial()) {
    on<PeoplePastFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => emit(state.copyWith(isLoading: !state.isLoading)),
        loadFriendsData: (event) => _loadFriendsData(emit, event.usersIds),
        startListening: (event) => _startListening(emit, event.felicitupId),
        recivedData: (event) => _recivedData(emit, event.invitedUsers),
      ),
    );
  }

  StreamSubscription<Either<ApiException, List<InvitedModel>>>?
  _invitedUsersSubscription;
  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;

  void _startListening(
    Emitter<PeoplePastFelicitupState> emit,
    String felicitupId,
  ) {
    _invitedUsersSubscription = _felicitupRepository
        .getInvitedStream(felicitupId)
        .listen((either) {
          either.fold((error) {}, (listUsers) {
            add(PeoplePastFelicitupEvent.recivedData(listUsers));
          });
        });
  }

  Future<void> _loadFriendsData(
    Emitter<PeoplePastFelicitupState> emit,
    List<String> usersIds,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _userRepository.getListUserData(usersIds);
      response.fold(
        (error) {
          logger.error(error);
          emit(state.copyWith(isLoading: false));
        },
        (users) {
          List<UserModel> usersList = [];
          for (final data in users) {
            usersList.add(UserModel.fromJson(data));
          }
          emit(state.copyWith(isLoading: false, friendList: usersList));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _recivedData(
    Emitter<PeoplePastFelicitupState> emit,
    List<InvitedModel> listUsers,
  ) async {
    emit(state.copyWith(invitedUsers: listUsers));
  }

  @override
  Future<void> close() {
    _invitedUsersSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
