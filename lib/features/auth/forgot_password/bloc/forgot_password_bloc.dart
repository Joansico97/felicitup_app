import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';
part 'forgot_password_bloc.freezed.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordState.initial()) {
    on<ForgotPasswordEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<ForgotPasswordState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
