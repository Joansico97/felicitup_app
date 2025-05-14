import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'federated_register_event.dart';
part 'federated_register_state.dart';
part 'federated_register_bloc.freezed.dart';

class FederatedRegisterBloc
    extends Bloc<FederatedRegisterEvent, FederatedRegisterState> {
  FederatedRegisterBloc({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required FirebaseFirestore firestore,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _firestore = firestore,
       super(FederatedRegisterState.initial()) {
    on<FederatedRegisterEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        initRegister:
            (event) => _initRegister(
              emit,
              event.name,
              event.lastName,
              event.genre,
              event.birthDate,
            ),
        savePhoneInfo:
            (event) => _savePhoneInfo(emit, event.phone, event.isoCode),
        initValidation: (_) => _initValidation(emit),
        validateCode: (event) => _validateCode(emit, event.code),
        setUserInfoRemaning: (_) => _setUserInfoRemaining(emit),
        finishEvent: (_) => _finishEvent(emit),
      ),
    );
  }

  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  _changeLoading(Emitter<FederatedRegisterState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _initRegister(
    Emitter<FederatedRegisterState> emit,
    String name,
    String lastName,
    String incommingGenre,
    DateTime birthDate,
  ) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(
      state.copyWith(
        isLoading: false,
        currentIndex: state.currentIndex + 1,
        name: name,
        lastName: lastName,
        genre: incommingGenre,
        birthDate: birthDate,
      ),
    );
  }

  _savePhoneInfo(
    Emitter<FederatedRegisterState> emit,
    String phone,
    String isoCode,
  ) async {
    emit(state.copyWith(isLoading: false, phone: phone, isoCode: isoCode));
    add(FederatedRegisterEvent.initValidation());
  }

  _initValidation(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final exist = await checkPhoneExist(
        phone: '${state.isoCode}${state.phone}',
      );
      if (exist) {
        emit(state.copyWith(isLoading: false));
        return;
      }
      await _authRepository.verifyPhone(
        phone: state.phone!,
        onCodeSent: (verificationId) {
          emit(
            state.copyWith(
              verificationId: verificationId,
              isLoading: false,
              currentIndex: state.currentIndex + 1,
            ),
          );
        },
        onError: (error) {
          emit(state.copyWith(isLoading: false));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _validateCode(Emitter<FederatedRegisterState> emit, String code) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _authRepository.confirmVerification(
        verificationId: state.verificationId!,
        smsCode: code,
        phoneNumber: '${state.isoCode}${state.phone}',
      );

      return response.fold(
        (l) {
          emit(state.copyWith(isLoading: false));
        },
        (r) {
          emit(state.copyWith(isLoading: false));
          add(FederatedRegisterEvent.setUserInfoRemaning());
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _setUserInfoRemaining(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.setUserInfoRemaining(
        state.name!,
        state.lastName!,
        state.phone!,
        state.isoCode!,
        state.genre!,
        state.birthDate!,
      );

      emit(
        state.copyWith(isLoading: false, currentIndex: state.currentIndex + 1),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _finishEvent(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 1), () {});
    emit(state.copyWith(isLoading: false));
  }

  Future<bool> checkPhoneExist({required String phone}) async {
    final docRef = _firestore.collection(AppConstants.usersCollection);
    final response = await docRef.where('phone', isEqualTo: phone).get();
    if (response.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
