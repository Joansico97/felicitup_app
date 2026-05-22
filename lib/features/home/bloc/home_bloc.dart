import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(HomeState.initial()) {
    on<HomeEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => emit(state.copyWith(
          isLoading: !state.isLoading,
          status: HomeStatus.initial,
        )),
        changeCreate: (_) => emit(state.copyWith(
          create: !state.create,
          status: HomeStatus.initial,
        )),
        setUserBirthdate: (event) => _setUserBirthdate(emit, event.date),
        changeShowButton: (_) => emit(state.copyWith(
          showButton: !state.showButton,
          status: HomeStatus.initial,
        )),
      ),
    );
  }

  final UserRepository _userRepository;

  Future<void> _setUserBirthdate(Emitter<HomeState> emit, DateTime date) async {
    emit(state.copyWith(isLoading: true, status: HomeStatus.loading));

    try {
      final response = await _userRepository.updateUserBirthdate(date);

      response.fold(
        (l) => emit(state.copyWith(isLoading: false, status: HomeStatus.error)),
        (r) => emit(state.copyWith(isLoading: false, status: HomeStatus.success)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, status: HomeStatus.error));
    }
  }
}
