import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'federated_register_event.dart';
part 'federated_register_state.dart';
part 'federated_register_bloc.freezed.dart';

class FederatedRegisterBloc
    extends Bloc<FederatedRegisterEvent, FederatedRegisterState> {
  FederatedRegisterBloc({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _firebaseAuth = firebaseAuth,
       _firestore = firestore,

       super(FederatedRegisterState.initial()) {
    on<FederatedRegisterEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        backStep: (_) => _backStep(emit),
        initRegister:
            (event) => _initRegister(
              emit,
              event.name,
              event.lastName,
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
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  _changeLoading(Emitter<FederatedRegisterState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _initRegister(
    Emitter<FederatedRegisterState> emit,
    String name,
    String lastName,
    DateTime? birthDate,
  ) async {
    await _setFormData(name, lastName, birthDate);

    emit(
      state.copyWith(isLoading: false, currentIndex: state.currentIndex + 1),
    );
  }

  _savePhoneInfo(
    Emitter<FederatedRegisterState> emit,
    String phone,
    String isoCode,
  ) async {
    final bytes = utf8.encode(phone);
    final digest = sha256.convert(bytes);
    final hashedPhone = digest.toString();

    final exist = await _userRepository.checkPhoneExist(phone: hashedPhone);

    return exist.fold(
      (l) {
        emit(
          state.copyWith(
            isLoading: false,
            status: FederatedRegisterStatus.error,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            isLoading: false,
            hashedPhone: hashedPhone,
            phone: phone,
            isoCode: isoCode,
          ),
        );
        add(const FederatedRegisterEvent.initValidation());
      },
    );
  }

  _initValidation(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _authRepository.verifyPhone(
        phone: '${state.phone}',
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
          emit(
            state.copyWith(
              isLoading: false,
              status: FederatedRegisterStatus.error,
              errorMessage: error.toString(),
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          status: FederatedRegisterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  _backStep(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(currentIndex: state.currentIndex - 1));
  }

  _validateCode(Emitter<FederatedRegisterState> emit, String code) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _authRepository
          .confirmVerification(
            verificationId: state.verificationId!,
            smsCode: code,
          )
          .timeout(const Duration(seconds: 30));

      return response.fold(
        (l) {
          FirebaseCrashlytics.instance.recordError(
            l,
            StackTrace.current,
            reason: 'Error al validar el código de verificación',
          );

          emit(
            state.copyWith(
              isLoading: false,
              status: FederatedRegisterStatus.error,
              errorMessage: l.message,
            ),
          );
        },
        (r) async {
          try {
            emit(
              state.copyWith(
                isLoading: false,
                currentIndex: state.currentIndex + 1,
              ),
            );
            add(FederatedRegisterEvent.setUserInfoRemaning());
          } catch (e) {
            emit(
              state.copyWith(
                isLoading: false,
                status: FederatedRegisterStatus.error,
                errorMessage: e.toString(),
              ),
            );
            FirebaseCrashlytics.instance.recordError(
              e,
              StackTrace.current,
              reason: 'Error al validar el código de verificación',
            );
          }
        },
      );
    } on TimeoutException {
      emit(
        state.copyWith(
          isLoading: false,
          status: FederatedRegisterStatus.error,
          errorMessage: 'Tiempo de espera agotado',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          status: FederatedRegisterStatus.error,
          errorMessage: e.toString(),
        ),
      );

      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Error al validar el código de verificación',
      );
    }
  }

  _setUserInfoRemaining(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = _firebaseAuth.currentUser?.uid;

      await _userRepository.setUserPhone(
        state.hashedPhone ?? '',
        state.isoCode ?? '',
        userId ?? '',
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

  _setFormData(String name, String lastName, DateTime? birthDate) async {
    await _userRepository.setUserInfoRemaining(
      name,
      lastName,
      state.phone ?? '',
      state.isoCode ?? '',
      state.genre ?? '',
    );
  }
}
