import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:felicitup_app/core/constants/app_constants.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';
part 'login_bloc.g.dart';

class LoginBloc extends HydratedBloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthRepository authRepository,
    required FirebaseFirestore firestore,
  }) : _authRepository = authRepository,
       _firestore = firestore,
       super(LoginState.initial()) {
    on<LoginEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        changeFirstTimeRedirect: (_) => _changeFirstTimeRedirect(emit),
        loginEvent: (event) => _loginEvent(emit, event.email, event.password),
        googleLoginEvent: (_) => _googleLoginEvent(emit),
        appleLoginEvent: (_) => _appleLoginEvent(emit),
        setUserInfo: (event) => _setUserInfo(emit, event.user),
        changeEvent: (_) => _changeEvent(emit),
      ),
    );
  }

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  _changeLoading(Emitter<LoginState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _changeFirstTimeRedirect(Emitter<LoginState> emit) {
    emit(state.copyWith(isFirstTime: false));
  }

  _loginEvent(Emitter<LoginState> emit, String email, String password) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      return response.fold(
        (l) {
          emit(
            state.copyWith(
              isLoading: false,
              status: LoginStatus.error,
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          emit(state.copyWith(isLoading: false, status: LoginStatus.success));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _googleLoginEvent(Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _authRepository.signInWithGoogle();

      return response.fold(
        (l) {
          emit(
            state.copyWith(
              isLoading: false,
              status: LoginStatus.error,
              errorMessage: l.message,
            ),
          );
        },
        (r) async {
          bool exist = await checkUserExist(email: r.user?.email ?? '');
          if (exist) {
            emit(state.copyWith(isLoading: false, status: LoginStatus.success));
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

            add(LoginEvent.setUserInfo(userModel));

            emit(
              state.copyWith(isLoading: false, status: LoginStatus.federated),
            );
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _setUserInfo(Emitter<LoginState> emit, UserModel user) async {
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
    });
  }

  _appleLoginEvent(Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _authRepository.signInWithApple();

      return response.fold(
        (l) {
          emit(
            state.copyWith(
              isLoading: false,
              status: LoginStatus.error,
              errorMessage: l.message,
            ),
          );
        },
        (r) async {
          bool exist = await checkUserExist(email: r.user?.email ?? '');
          if (exist) {
            emit(state.copyWith(isLoading: false, status: LoginStatus.success));
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

            add(LoginEvent.setUserInfo(userModel));
            emit(
              state.copyWith(isLoading: false, status: LoginStatus.federated),
            );
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _changeEvent(Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.inProgress));
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

  @override
  LoginState? fromJson(Map<String, dynamic> json) {
    try {
      return LoginState(
        errorMessage: json['errorMessage'] as String? ?? '',
        isLoading: json['isLoading'] as bool? ?? false,
        isFirstTime: json['isFirstTime'] as bool? ?? true,
        status: LoginStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => LoginStatus.inProgress,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(LoginState state) {
    return state.toJson();
  }
}
