import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(ProfileState.initial()) {
    on<ProfileEvent>(
      (events, emit) => events.map(
        changeLoading: (event) => _changeLoading(emit),
        updateUserImageFromUrl: (event) => _updateUserImageFromUrl(emit, event.url),
        updateUserInfo: (event) => _updateUserInfo(emit, event.user),
        updateUserImageFromFile: (event) => _updateUserImageFromFile(emit, event.file),
      ),
    );
  }

  final UserRepository _userRepository;

  _changeLoading(Emitter<ProfileState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _updateUserImageFromUrl(Emitter<ProfileState> emit, String url) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.updateUserImageFromUrl(url);
      response.fold(
        (l) => emit(state.copyWith(isLoading: false)),
        (r) => emit(state.copyWith(isLoading: false, status: ProfileStatus.success)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _updateUserImageFromFile(Emitter<ProfileState> emit, File file) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.updateUserImageFromFile(file);
      return response.fold(
        (l) => emit(state.copyWith(isLoading: false)),
        (r) => emit(
          state.copyWith(
            isLoading: false,
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _updateUserInfo(Emitter<ProfileState> emit, UserModel user) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.updateUserInfo(user);
      return response.fold(
        (l) => emit(state.copyWith(isLoading: false)),
        (r) => emit(state.copyWith(isLoading: false, status: ProfileStatus.success)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
