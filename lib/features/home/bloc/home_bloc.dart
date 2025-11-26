import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HashedContact {
  final String displayName;
  final String hashedPhone;

  HashedContact({required this.displayName, required this.hashedPhone});
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(HomeState.initial()) {
    on<HomeEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => emit(state.copyWith(isLoading: !state.isLoading)),
        changeCreate: (_) => emit(state.copyWith(create: !state.create)),
        setUserBirthdate: (event) => _setUserBirthdate(emit, event.date),
        changeShowButton: (_) =>
            emit(state.copyWith(showButton: !state.showButton)),
        getAndUpdateContacts: (event) =>
            _getAndUpdateContacts(emit, event.isoCode),
      ),
    );
  }

  final UserRepository _userRepository;

  Future<void> _getAndUpdateContacts(
    Emitter<HomeState> emit,
    String isoCode,
  ) async {}

  Future<void> _setUserBirthdate(Emitter<HomeState> emit, DateTime date) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _userRepository.updateUserBirthdate(date);

      response.fold(
        (l) {
          emit(state.copyWith(isLoading: false));
          throw l;
        },
        (r) {
          emit(state.copyWith(isLoading: false));
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Fecha de cumpleaños actualizada correctamente',
                style: rootNavigatorKey.currentContext!.styles.paragraph
                    .copyWith(
                      color: rootNavigatorKey.currentContext!.colors.white,
                    ),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
