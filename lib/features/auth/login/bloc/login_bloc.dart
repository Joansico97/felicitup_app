import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(LoginState.initial()) {
    on<LoginEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        loginEvent: (event) => _loginEvent(emit, event.email, event.password),
      ),
    );
  }

  final AuthRepository _authRepository;

  _changeLoading(Emitter<LoginState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _loginEvent(Emitter<LoginState> emit, String email, String password) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _authRepository.login(email: email, password: password);

      response.fold(
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
          emit(
            state.copyWith(
              isLoading: false,
              status: LoginStatus.success,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
