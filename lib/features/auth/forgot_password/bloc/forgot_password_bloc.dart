import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/repositories/auth_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';
part 'forgot_password_bloc.freezed.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(ForgotPasswordState.initial()) {
    on<ForgotPasswordEvent>(
      (events, emit) => events.map(
        sendEmailEvent: (event) => _sendEmailEvent(emit, event.email),
      ),
    );
  }

  final AuthRepository _authRepository;

  _sendEmailEvent(Emitter<ForgotPasswordState> emit, String email) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _authRepository.forgotPassword(email: email);

      response.fold(
        (error) {
          emit(state.copyWith(isLoading: false));
        },
        (success) {
          emit(state.copyWith(isLoading: false));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
