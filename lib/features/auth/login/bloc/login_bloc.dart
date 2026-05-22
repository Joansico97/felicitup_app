import 'dart:async';

import 'package:felicitup_app/core/analytics/analytics_handler.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';
part 'login_bloc.g.dart';

class LoginBloc extends HydratedBloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required AnalyticsHandler analyticsHandler,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _analyticsHandler = analyticsHandler,
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
  final UserRepository _userRepository;
  final AnalyticsHandler _analyticsHandler;

  void _changeLoading(Emitter<LoginState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  void _changeFirstTimeRedirect(Emitter<LoginState> emit) {
    emit(state.copyWith(isFirstTime: false));
  }

  Future<Null> _loginEvent(
    Emitter<LoginState> emit,
    String email,
    String password,
  ) async {
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
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // The user id will be automatically set by the firebase analytics sdk
          }
          _analyticsHandler.logLogin();
          emit(state.copyWith(isLoading: false, status: LoginStatus.success));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<Future<Null>?>? _googleLoginEvent(Emitter<LoginState> emit) async {
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
          return null;
        },
        (r) async {
          final existResponse = await _userRepository.checkEmailExist(
            email: r.user?.email ?? '',
          );
          bool exist = existResponse.fold((l) => false, (r) => r);
          if (exist) {
            if (r.user?.uid != null) {
              // The user id will be automatically set by the firebase analytics sdk
            }
            _analyticsHandler.logLogin();
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
          return null;
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
    return null;
  }

  Future<void> _setUserInfo(Emitter<LoginState> emit, UserModel user) async {
    await _userRepository.setInitialUserInfo(user);
  }

  Future<Future<Null>?>? _appleLoginEvent(Emitter<LoginState> emit) async {
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
          return null;
        },
        (r) async {
          final data = r['credential'] as UserCredential?;
          final user = data?.user;

          final existResponse = await _userRepository.checkEmailExist(
            email: user?.email ?? '',
          );
          bool exist = existResponse.fold((l) => false, (r) => r);
          if (exist) {
            if (user?.uid != null) {
              // The user id will be automatically set by the firebase analytics sdk
            }
            _analyticsHandler.logLogin();
            emit(state.copyWith(isLoading: false, status: LoginStatus.success));
          } else {
            emit(
              state.copyWith(isLoading: false, status: LoginStatus.federated),
            );
          }
          return null;
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
    return null;
  }

  Future<void> _changeEvent(Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.inProgress));
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
