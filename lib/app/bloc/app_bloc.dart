import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_event.dart';
part 'app_state.dart';
part 'app_bloc.freezed.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  })  : _userRepository = userRepository,
        _authRepository = authRepository,
        super(AppState.initial()) {
    on<AppEvent>(
      (event, emit) => event.map(
        changeLoading: (_) => _changeLoading(emit),
        loadUserData: (_) => _loadUserData(emit),
        logout: (_) => _logout(emit),
      ),
    );
  }

  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  _changeLoading(Emitter<AppState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _loadUserData(Emitter<AppState> emit) async {
    logger.debug('loadUserData');
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.getUserData(FirebaseAuth.instance.currentUser?.uid ?? '');

      response.fold(
        (error) {
          emit(state.copyWith(isLoading: false));
        },
        (data) {
          emit(state.copyWith(
            isLoading: false,
            currentUser: UserModel.fromJson(data),
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _logout(Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _authRepository.logout();
      emit(state.copyWith(
        isLoading: false,
        currentUser: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
