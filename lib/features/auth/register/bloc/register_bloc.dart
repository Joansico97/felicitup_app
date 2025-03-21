import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_event.dart';
part 'register_state.dart';
part 'register_bloc.freezed.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(RegisterState.initial()) {
    on<RegisterEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        initRegister: (event) => _initRegister(
          emit,
          event.name,
          event.lastName,
          event.email,
          event.password,
          event.confirmPassword,
          event.gender,
          event.birthDate,
        ),
        savePhoneInfo: (event) => _savePhoneInfo(emit, event.phone, event.isoCode),
        initValidation: (_) => _initValidation(emit),
        registerEvent: (_) => _registerEvent(emit),
        setUserInfo: (event) => _setUserInfo(emit, event.credential),
        finishEvent: (_) => _finishEvent(emit),
      ),
    );
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  _changeLoading(Emitter<RegisterState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _initRegister(
    Emitter<RegisterState> emit,
    String name,
    String lastName,
    String email,
    String password,
    String confirmPassword,
    String gender,
    DateTime birthDate,
  ) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(state.copyWith(
      isLoading: false,
      status: RegisterStatus.formFinished,
      name: name,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      gender: gender,
      birthDate: birthDate,
    ));
  }

  _savePhoneInfo(Emitter<RegisterState> emit, String phone, String isoCode) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(state.copyWith(isLoading: false, phone: phone, isoCode: isoCode));
  }

  _initValidation(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(state.copyWith(isLoading: false, status: RegisterStatus.validateCode));
  }

  _setUserInfo(Emitter<RegisterState> emit, UserCredential userCredential) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.setInitialUserInfo(
        UserModel(
          id: userCredential.user!.uid,
          firstName: state.name!,
          lastName: state.lastName!,
          fullName: '${state.name} ${state.lastName}',
          email: userCredential.user!.email,
          isoCode: state.isoCode!,
          phone: state.phone!,
          fcmToken: '',
          currentChat: '',
          userImg: state.gender == 'Masculino'
              ? 'https://firebasestorage.googleapis.com/v0/b/felicitup-prod.appspot.com/o/commonFiles%2Favatares%2Favatar_man_1.png?alt=media&token=11af323b-5266-422b-94c4-5a176a931ec0'
              : state.gender == 'Femenino'
                  ? 'https://firebasestorage.googleapis.com/v0/b/felicitup-prod.appspot.com/o/commonFiles%2Favatares%2Favatar_woman_1.png?alt=media&token=23a0d5b4-22d4-4e76-9f77-6250fc1ca163'
                  : '',
          friendList: [],
          birthdateAlerts: [],
          matchList: [],
          friendsPhoneList: [],
          giftcardList: [],
          notifications: [],
          singleChats: [],
          birthDate: state.birthDate!,
          registerDate: DateTime.now(),
        ),
      );
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _registerEvent(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true)); // Indica que la operación está en progreso

    try {
      final response = await _authRepository.register(
        email: state.email!,
        password: state.password!,
      );

      response.fold(
        (l) {
          // Si hay un error en el registro
          emit(
            state.copyWith(
              isLoading: false,
              status: RegisterStatus.error,
              errorMessage: l.toString(),
            ),
          );
        },
        (r) {
          add(RegisterEvent.setUserInfo(r));
          emit(
            state.copyWith(
              isLoading: false,
              status: RegisterStatus.success,
            ),
          );
        },
      );
    } catch (e) {
      // Si hay un error en el proceso de registro
      emit(
        state.copyWith(
          isLoading: false,
          status: RegisterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  _finishEvent(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(state.copyWith(isLoading: false, status: RegisterStatus.finished));
  }
}
