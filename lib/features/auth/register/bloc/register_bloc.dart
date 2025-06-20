import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'register_event.dart';
part 'register_state.dart';
part 'register_bloc.freezed.dart';
part 'register_bloc.g.dart';

class RegisterBloc extends HydratedBloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required FirebaseFirestore firestore,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _firestore = firestore,
       super(RegisterState.initial()) {
    on<RegisterEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        changeStatus: (event) => _changeStatus(emit, event.status),
        previousStep: (_) => _previousStep(emit),
        googleLoginEvent: (_) => _googleLoginEvent(emit),
        appleLoginEvent: (_) => _appleLoginEvent(emit),
        initRegister:
            (event) => _initRegister(
              emit,
              event.name,
              event.lastName,
              event.email,
              event.password,
              event.confirmPassword,
              event.genre,
              event.birthDate,
            ),
        validateCode: (value) => _validateCode(emit, value.code),
        verificationCompleted:
            (event) => _verificationCompleted(emit, event.verificationId),
        verificationFailed: (event) => _verificationFailed(emit, event.error),
        savePhoneInfo:
            (event) => _savePhoneInfo(emit, event.phone, event.isoCode),
        initValidation: (_) => _initValidation(emit),
        registerEvent: (_) => _registerEvent(emit),
        setUserInfo: (event) => _setUserInfo(emit, event.credential),
        finishEvent: (_) => _finishEvent(emit),
      ),
    );
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final FirebaseFirestore _firestore;

  _changeLoading(Emitter<RegisterState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _changeStatus(Emitter<RegisterState> emit, RegisterStatus status) {
    emit(state.copyWith(status: status));
  }

  _previousStep(Emitter<RegisterState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  _initRegister(
    Emitter<RegisterState> emit,
    String name,
    String lastName,
    String email,
    String password,
    String confirmPassword,
    String genre,
    DateTime birthDate,
  ) {
    emit(
      state.copyWith(
        status: RegisterStatus.formFinished,
        currentStep: state.currentStep + 1,
        name: name,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        genre: genre,
        birthDate: birthDate,
      ),
    );
  }

  _savePhoneInfo(
    Emitter<RegisterState> emit,
    String phone,
    String isoCode,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, currentStep: state.currentStep + 1));

      final exist = await checkPhoneExist(phone: phone);
      if (exist) {
        emit(
          state.copyWith(
            isLoading: false,
            status: RegisterStatus.error,
            errorMessage: 'El número de teléfono ya está registrado.',
          ),
        );
        return;
      }

      emit(state.copyWith(isLoading: false, phone: phone, isoCode: isoCode));
      add(RegisterEvent.initValidation());
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

  _initValidation(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));

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

  _verificationCompleted(Emitter<RegisterState> emit, String verificationId) {
    emit(
      state.copyWith(
        verificationId: verificationId,
        isLoading: false,
        status: RegisterStatus.validateCode,
      ),
    );
  }

  _verificationFailed(Emitter<RegisterState> emit, String error) {
    emit(
      state.copyWith(
        isLoading: false,
        status: RegisterStatus.error,
        errorMessage: error,
        currentStep: 0,
      ),
    );
  }

  _validateCode(Emitter<RegisterState> emit, String code) async {
    emit(state.copyWith(isLoading: true));
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

  _setUserInfo(
    Emitter<RegisterState> emit,
    UserCredential userCredential,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.setInitialUserInfo(
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
          userImg:
              state.genre == 'Masculino'
                  ? Env.avatar3
                  : state.genre == 'Femenino'
                  ? Env.avatar1
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
          birthDay: state.birthDate!.day,
          birthMonth: state.birthDate!.month,
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

  _registerEvent(Emitter<RegisterState> emit) async {
    emit(
      state.copyWith(isLoading: true),
    ); // Indica que la operación está en progreso

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

  _googleLoginEvent(Emitter<RegisterState> emit) async {
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
          bool exist = await checkUserExist(email: r.user?.email ?? '');
          if (exist) {
            emit(
              state.copyWith(
                isLoading: false,
                status: RegisterStatus.federatedFinished,
              ),
            );
          } else {
            final user = r.user;
            final userModel = UserModel(
              id: user?.uid,
              firstName: user?.displayName?.split(' ')[0],
              lastName: user?.displayName?.split(' ')[1],
              fullName: user?.displayName,
              userImg: user?.photoURL,
              email: user?.email,
              birthDate: DateTime.now(),
              registerDate: DateTime.now(),
              phone: '',
              isoCode: '',
              friendList: [],
              giftcardList: [],
              matchList: [],
              fcmToken: '',
            );

            _setUserInfoRegister(userModel);

            emit(
              state.copyWith(
                isLoading: false,
                status: RegisterStatus.federated,
                federatedUser: {
                  'firstName': user?.displayName?.split(' ')[0] ?? '',
                  'lastName': user?.displayName?.split(' ')[1] ?? '',
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

  _appleLoginEvent(Emitter<RegisterState> emit) async {
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
          bool exist = await checkUserExist(email: r.user?.email ?? '');
          if (exist) {
            emit(
              state.copyWith(
                isLoading: false,
                status: RegisterStatus.federatedFinished,
              ),
            );
          } else {
            final user = r.user;
            final userModel = UserModel(
              id: user?.uid,
              firstName: user?.displayName?.split(' ')[0],
              lastName: user?.displayName?.split(' ')[1],
              fullName: user?.displayName,
              userImg: '',
              email: user?.email,
              birthDate: DateTime.now(),
              registerDate: DateTime.now(),
              phone: '',
              isoCode: '',
              friendList: [],
              giftcardList: [],
              matchList: [],
              fcmToken: '',
            );

            _setUserInfoRegister(userModel);
            emit(
              state.copyWith(
                isLoading: false,
                status: RegisterStatus.federated,
                federatedUser: {
                  'firstName': user?.displayName?.split(' ')[0] ?? '',
                  'lastName': user?.displayName?.split(' ')[1] ?? '',
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

  _finishEvent(Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Duration(seconds: 3), () {});
    emit(state.copyWith(isLoading: false, status: RegisterStatus.finished));
  }

  Future<bool> checkUserExist({required String email}) async {
    final docRef = _firestore.collection(AppConstants.usersCollection);
    final response = await docRef.where('email', isEqualTo: email).get();
    if (response.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
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

  _setUserInfoRegister(UserModel user) async {
    await _firestore.collection(AppConstants.usersCollection).doc(user.id).set({
      'id': user.id,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'fullName': user.fullName,
      'userImg': user.userImg,
      'email': user.email,
      'birthDate': DateTime.now(),
      'registerDate': DateTime.now(),
      'phone': '',
      'isoCode': '',
      'friendList': [],
      'giftcardList': [],
      'matchList': [],
      'fcmToken': '',
      'genre': '',
      'provider': 'federated',
    });
  }

  @override
  RegisterState? fromJson(Map<String, dynamic> json) {
    return RegisterState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(RegisterState state) {
    return state.toJson();
  }
}
