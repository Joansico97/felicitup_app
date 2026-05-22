import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:felicitup_app/core/analytics/analytics_handler.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'register_event.dart';
part 'register_state.dart';
part 'register_bloc.freezed.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required AnalyticsHandler analyticsHandler,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _analyticsHandler = analyticsHandler,
       super(RegisterState.initial()) {
    on<RegisterEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        changeStatus: (event) => _changeStatus(emit, event.status),
        previousStep: (_) => _previousStep(emit),
        googleLoginEvent: (_) => _googleLoginEvent(emit),
        appleLoginEvent: (_) => _appleLoginEvent(emit),
        initRegister: (event) => _initRegister(
          emit,
          event.name,
          event.lastName,
          event.email,
          event.password,
          event.confirmPassword,
          event.birthDate,
        ),
        validateCode: (value) => _validateCode(emit, value.code),
        verificationCompleted: (event) =>
            _verificationCompleted(emit, event.verificationId),
        verificationFailed: (event) => _verificationFailed(emit, event.error),
        savePhoneInfo: (event) =>
            _savePhoneInfo(emit, event.phone, event.isoCode),
        initValidation: (_) => _initValidation(emit),
        registerEvent: (_) => _registerEvent(emit),
        setUserInfo: (event) => _setUserInfo(emit, event.credential),
        finishEvent: (_) => _finishEvent(emit),
        deleteState: (_) => emit(RegisterState.initial()),
      ),
    );
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final AnalyticsHandler _analyticsHandler;

  String _normalizePhone(String rawPhone) {
    final trimmed = rawPhone.trim();
    final buffer = StringBuffer();
    for (int i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      if (i == 0 && char == '+') {
        buffer.write(char);
        continue;
      }
      if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  String _hashString(String value) {
    final bytes = utf8.encode(value);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Map<String, String> _parseNames(String? fullName) {
    final safe = (fullName ?? '').trim();
    if (safe.isEmpty) return {'first': '', 'last': ''};
    final parts = safe
        .split(RegExp(r"\s+"))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      return {'first': parts.first, 'last': ''};
    }
    return {'first': parts.first, 'last': parts.sublist(1).join(' ')};
  }

  void _changeLoading(Emitter<RegisterState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  void _changeStatus(Emitter<RegisterState> emit, RegisterStatus status) {
    emit(state.copyWith(status: status));
  }

  void _previousStep(Emitter<RegisterState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> _initRegister(
    Emitter<RegisterState> emit,
    String name,
    String lastName,
    String email,
    String password,
    String confirmPassword,
    DateTime? birthDate,
  ) async {
    emit(state.copyWith(isLoading: true, status: RegisterStatus.initial));
    bool isError = false;
    final isDomainValid = await _authRepository.validateEmailDomain(
      email: email,
    );
    isDomainValid.fold(
      (l) {
        isError = true;
        emit(
          state.copyWith(
            isLoading: false,
            status: RegisterStatus.error,
            errorMessage: 'Error al validar el dominio del correo.',
          ),
        );
      },
      (r) {
        final (isValid, suggestion) = r;
        if (!isValid) {
          isError = true;
          String errorMessage =
              'El dominio del correo electrónico no es válido.';
          if (suggestion != null) {
            errorMessage =
                'El dominio no es válido. ¿Quisiste decir $suggestion?';
          }
          emit(
            state.copyWith(
              isLoading: false,
              status: RegisterStatus.error,
              errorMessage: errorMessage,
            ),
          );
        }
      },
    );

    if (isError) {
      return;
    }

    emit(
      state.copyWith(
        isLoading: false,
        status: RegisterStatus.formFinished,
        currentStep: state.currentStep + 1,
        name: name,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        birthDate: birthDate,
      ),
    );
  }

  Future<void> _savePhoneInfo(
    Emitter<RegisterState> emit,
    String phone,
    String isoCode,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      final normalizedPhone = _normalizePhone(phone);
      final hashedPhone = _hashString(normalizedPhone);

      final exist = await _userRepository.checkPhoneExist(phone: hashedPhone);

      return exist.fold(
        (l) {
          emit(
            state.copyWith(
              isLoading: false,
              status: RegisterStatus.error,
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          if (r) {
            emit(
              state.copyWith(
                isLoading: false,
                status: RegisterStatus.error,
                errorMessage: 'El número de teléfono ya está registrado.',
              ),
            );
          } else {
            emit(
              state.copyWith(
                isLoading: false,
                hashedPhone: hashedPhone,
                phone: normalizedPhone,
                isoCode: isoCode,
                currentStep: state.currentStep + 1,
              ),
            );
            add(RegisterEvent.initValidation());
          }
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          status: RegisterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _initValidation(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true, status: RegisterStatus.initial));

    try {
      await _authRepository.verifyPhone(
        phone: state.phone!,
        onCodeSent: (verificationId) {
          if (isClosed) return;
          add(RegisterEvent.verificationCompleted(verificationId));
        },
        onError: (error) {
          if (isClosed) return;
          add(RegisterEvent.verificationFailed(error.toString()));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          status: RegisterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _verificationCompleted(
    Emitter<RegisterState> emit,
    String verificationId,
  ) {
    emit(
      state.copyWith(
        verificationId: verificationId,
        isLoading: false,
        status: RegisterStatus.validateCode,
      ),
    );
  }

  void _verificationFailed(Emitter<RegisterState> emit, String error) {
    emit(
      state.copyWith(
        isLoading: false,
        status: RegisterStatus.error,
        errorMessage: error,
        currentStep: 0,
      ),
    );
  }

  Future<Null> _validateCode(Emitter<RegisterState> emit, String code) async {
    emit(state.copyWith(isLoading: true, status: RegisterStatus.initial));
    try {
      final response = await _authRepository.confirmVerification(
        verificationId: state.verificationId!,
        smsCode: code,
      );

      return response.fold(
        (l) {
          emit(
            state.copyWith(
              isLoading: false,
              status: RegisterStatus.error,
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          emit(
            state.copyWith(
              isLoading: false,
              currentStep: state.currentStep + 1,
            ),
          );
          add(RegisterEvent.registerEvent(true));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          status: RegisterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _setUserInfo(
    Emitter<RegisterState> emit,
    UserCredential userCredential,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final DateTime? localBirthDate = state.birthDate?.toLocal();
      final response = await _userRepository.setInitialUserInfo(
        UserModel(
          id: userCredential.user!.uid,
          firstName: state.name!,
          lastName: state.lastName!,
          fullName: '${state.name} ${state.lastName}',
          email: userCredential.user!.email,
          isoCode: state.isoCode!,
          phone: state.hashedPhone!,
          fcmToken: '',
          currentChat: '',
          userImg: Env.avatar3,
          friendList: [],
          birthdateAlerts: [],
          matchList: [],
          friendsPhoneList: [],
          giftcardList: [],
          notifications: [],
          singleChats: [],
          birthDate: localBirthDate,
          registerDate: DateTime.now(),
          birthDay: localBirthDate?.day,
          birthMonth: localBirthDate?.month,
          provider: 'email',
        ),
      );

      return response.fold(
        (l) {
          emit(state.copyWith(isLoading: false));
        },
        (r) {
          emit(state.copyWith(isLoading: false));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _registerEvent(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _authRepository.register(
        email: state.email!,
        password: state.password!,
      );

      return response.fold(
        (l) {
          emit(
            state.copyWith(
              isLoading: false,
              status: RegisterStatus.error,
              errorMessage: l.toString(),
            ),
          );
        },
        (r) async {
          add(RegisterEvent.setUserInfo(r));
          if (r.user != null) {
            // The user id will be automatically set by the firebase analytics sdk
          }
          _analyticsHandler.logSignUp(signUpMethod: 'email');
          emit(
            state.copyWith(isLoading: false, status: RegisterStatus.success),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          status: RegisterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _googleLoginEvent(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _authRepository.signInWithGoogle();

      return response.fold(
        (l) {
          emit(
            state.copyWith(
              isLoading: false,
              status: RegisterStatus.error,
              errorMessage: l.message,
            ),
          );
        },
        (r) async {
          final existResponse = await _userRepository.checkEmailExist(
            email: (r.user?.email ?? '').trim().toLowerCase(),
          );
          bool exist = existResponse.fold((l) => false, (r) => r);
          if (exist) {
            emit(
              state.copyWith(
                isLoading: false,
                status: RegisterStatus.federatedFinished,
              ),
            );
          } else {
            final user = r.user;
            final parsed = _parseNames(user?.displayName);
            final userModel = UserModel(
              id: user?.uid,
              firstName: parsed['first'],
              lastName: parsed['last'],
              fullName: user?.displayName,
              userImg: user?.photoURL,
              email: user?.email,
              birthDate: null,
              birthDay: null,
              birthMonth: null,
              registerDate: DateTime.now(),
              phone: '',
              isoCode: '',
              friendList: [],
              giftcardList: [],
              matchList: [],
              fcmToken: '',
              provider: 'federated',
            );

            _setUserInfoRegister(userModel);

            if (userModel.id != null) {
              // The user id will be automatically set by the firebase analytics sdk
            }
            _analyticsHandler.logSignUp(signUpMethod: 'google');

            emit(
              state.copyWith(
                isLoading: false,
                status: RegisterStatus.federated,
                federatedUser: {
                  'firstName': parsed['first'] ?? '',
                  'lastName': parsed['last'] ?? '',
                },
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _appleLoginEvent(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _authRepository.signInWithApple();

      return response.fold(
        (l) {
          emit(
            state.copyWith(
              isLoading: false,
              status: RegisterStatus.error,
              errorMessage: l.message,
            ),
          );
        },
        (r) async {
          final data = r['credential'] as UserCredential?;
          final user = data?.user;

          final existResponse = await _userRepository.checkEmailExist(
            email: (user?.email ?? '').trim().toLowerCase(),
          );
          bool exist = existResponse.fold((l) => false, (r) => r);
          if (exist) {
            emit(
              state.copyWith(
                isLoading: false,
                status: RegisterStatus.federatedFinished,
              ),
            );
          } else {
            final appleData = r['data'] as AuthorizationCredentialAppleID?;
            final userModel = UserModel(
              id: user?.uid,
              firstName: appleData?.givenName ?? '',
              lastName: appleData?.familyName ?? '',
              fullName:
                  '${appleData?.givenName ?? ''} ${appleData?.familyName ?? ''}',
              userImg: '',
              email: user?.email ?? '',
              birthDate: null,
              birthDay: null,
              birthMonth: null,
              registerDate: DateTime.now(),
              userIdentifier: appleData?.userIdentifier,
              phone: '',
              isoCode: '',
              friendList: [],
              giftcardList: [],
              matchList: [],
              fcmToken: '',
              provider: 'federated',
            );

            _setUserInfoRegister(userModel);
            if (userModel.id != null) {
              // The user id will be automatically set by the firebase analytics sdk
            }
            _analyticsHandler.logSignUp(signUpMethod: 'apple');

            emit(
              state.copyWith(
                isLoading: false,
                status: RegisterStatus.federated,
                federatedUser: {
                  'firstName': appleData?.givenName ?? '',
                  'lastName': appleData?.familyName ?? '',
                },
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _finishEvent(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 3), () {});
    emit(state.copyWith(isLoading: false, status: RegisterStatus.finished));
  }

  Future<void> _setUserInfoRegister(UserModel user) async {
    await _userRepository.setInitialUserInfo(user);
  }
}
