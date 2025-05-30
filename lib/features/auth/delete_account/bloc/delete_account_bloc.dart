import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/logger.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_account_event.dart';
part 'delete_account_state.dart';
part 'delete_account_bloc.freezed.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  DeleteAccountBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(DeleteAccountState.initial()) {
    on<DeleteAccountEvent>(
      (event, emit) => event.map(
        deleteAccountEvent:
            (event) => _deleteAccountEvent(emit, event.userId, event.answers),
      ),
    );
  }

  final UserRepository _userRepository;

  _deleteAccountEvent(
    Emitter<DeleteAccountState> emit,
    String userId,
    List<String> answers,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _userRepository.deleteAccount(
        userId: userId,
        answers: answers,
      );
      result.fold((error) => logger.error('Error deleting account: $error'), (
        _,
      ) {
        emit(state.copyWith(isLoading: false));
      });

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
