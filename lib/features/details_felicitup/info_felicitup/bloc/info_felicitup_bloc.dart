import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'info_felicitup_event.dart';
part 'info_felicitup_state.dart';
part 'info_felicitup_bloc.freezed.dart';

class InfoFelicitupBloc extends Bloc<InfoFelicitupEvent, InfoFelicitupState> {
  InfoFelicitupBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
  })  : _felicitupRepository = felicitupRepository,
        _userRepository = userRepository,
        super(InfoFelicitupState.initial()) {
    on<InfoFelicitupEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        sendFelicitup: (event) => _sendFelicitup(emit, event.felicitupId),
        updateDateFelicitup: (event) => _updateDateFelicitup(emit, event.felicitupId, event.newDate),
        addToOwnerList: (event) => _addToOwnerList(emit, event.felicitupOwner),
        updateFelicitupOwners: (event) => _updateFelicitupOwners(emit, event.felicitupId),
        loadFriendsData: (event) => _loadFriendsData(emit, event.usersIds),
      ),
    );
  }

  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;

  _changeLoading(Emitter<InfoFelicitupState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _sendFelicitup(Emitter<InfoFelicitupState> emit, String felicitupId) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _felicitupRepository.sendFelicitup(felicitupId);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _updateDateFelicitup(Emitter<InfoFelicitupState> emit, String felicitupId, DateTime newDate) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _felicitupRepository.updateDateFelicitup(felicitupId, newDate);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _addToOwnerList(Emitter<InfoFelicitupState> emit, OwnerModel owner) async {
    final List<OwnerModel> owners = [...state.ownersList];
    bool exist = owners.any((element) => element == owner);
    if (!exist) {
      owners.add(owner);
    } else {
      owners.remove(owner);
    }
    emit(state.copyWith(ownersList: owners));
  }

  _updateFelicitupOwners(Emitter<InfoFelicitupState> emit, String felicitupId) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _felicitupRepository.updateFelicitupOwner(felicitupId, state.ownersList);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _loadFriendsData(Emitter<InfoFelicitupState> emit, List<String> usersIds) async {
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
}
