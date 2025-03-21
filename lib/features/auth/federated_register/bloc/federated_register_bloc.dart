import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'federated_register_event.dart';
part 'federated_register_state.dart';
part 'federated_register_bloc.freezed.dart';

class FederatedRegisterBloc extends Bloc<FederatedRegisterEvent, FederatedRegisterState> {
  FederatedRegisterBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(FederatedRegisterState.initial()) {
    on<FederatedRegisterEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        initRegister: (event) => _initRegister(
          emit,
          event.name,
          event.lastName,
          event.gender,
          event.birthDate,
        ),
        savePhoneInfo: (event) => _savePhoneInfo(emit, event.phone, event.isoCode),
        initValidation: (_) => _initValidation(emit),
        setUserInfoRemaning: (_) => _setUserInfoRemaining(
          emit,
        ),
        finishEvent: (_) => _finishEvent(emit),
      ),
    );
  }

  final UserRepository _userRepository;

  _changeLoading(Emitter<FederatedRegisterState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _initRegister(
    Emitter<FederatedRegisterState> emit,
    String name,
    String lastName,
    String gender,
    DateTime birthDate,
  ) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(state.copyWith(
      isLoading: false,
      currentIndex: state.currentIndex + 1,
      name: name,
      lastName: lastName,
      gender: gender,
      birthDate: birthDate,
    ));
  }

  _savePhoneInfo(Emitter<FederatedRegisterState> emit, String phone, String isoCode) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(state.copyWith(isLoading: false, phone: phone, isoCode: isoCode, currentIndex: state.currentIndex + 1));
  }

  _initValidation(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(state.copyWith(isLoading: false, currentIndex: state.currentIndex + 1));
  }

  _setUserInfoRemaining(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.setUserInfoRemaining(
        state.name!,
        state.lastName!,
        state.phone!,
        state.isoCode!,
        state.gender!,
        state.birthDate!,
      );

      emit(state.copyWith(isLoading: false, currentIndex: state.currentIndex + 1));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _finishEvent(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(state.copyWith(isLoading: false));
  }
}
