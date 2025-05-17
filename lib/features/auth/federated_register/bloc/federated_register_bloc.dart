import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/extensions/context_extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final FirebaseAuth _firebaseAuth;
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
    final response = await _userRepository.setFederatedData(
      firstName: name,
      lastName: lastName,
      genre: incommingGenre,
      birthDate: birthDate,
    );

    response.fold(
      (l) {
        emit(state.copyWith(isLoading: false));
      },
      (r) {
        final userId = _firebaseAuth.currentUser?.uid;
        emit(
          state.copyWith(
            isLoading: false,
            currentIndex: state.currentIndex + 1,
            userId: userId,
          ),
        );
      },
    );
  }

  _savePhoneInfo(
    Emitter<FederatedRegisterState> emit,
    String phone,
    String isoCode,
  ) async {
    emit(state.copyWith(phone: phone, isoCode: isoCode));
    final currentUser = _firebaseAuth.currentUser!;
    await _userRepository.setUserPhone(
      state.phone!,
      state.isoCode!,
      currentUser.uid,
    );
    add(FederatedRegisterEvent.initValidation());
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
          emit(state.copyWith(isLoading: false));
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                error,
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
          emit(state.copyWith(isLoading: false));
          // ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       l.message,
          //       style: rootNavigatorKey.currentContext!.styles.paragraph
          //           .copyWith(
          //             color: rootNavigatorKey.currentContext!.colors.white,
          //           ),
          //     ),
          //     duration: const Duration(seconds: 5),
          //   ),
          // );
          emit(
            state.copyWith(
              isLoading: false,
              currentIndex: state.currentIndex + 1,
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
          } catch (e) {
            // ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       '$e',
            //       style: rootNavigatorKey.currentContext!.styles.paragraph
            //           .copyWith(
            //             color: rootNavigatorKey.currentContext!.colors.white,
            //           ),
            //     ),
            //     duration: const Duration(seconds: 5),
            //   ),
            // );
            emit(
              state.copyWith(
                isLoading: false,
                currentIndex: state.currentIndex + 1,
              ),
            );
          }
        },
      );
    } on TimeoutException {
      logger.error('Tiempo de espera agotado');
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _setUserInfoRemaining(Emitter<FederatedRegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = _firebaseAuth.currentUser?.uid;

      await _userRepository.setUserPhone(
        state.phone ?? '',
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
}
