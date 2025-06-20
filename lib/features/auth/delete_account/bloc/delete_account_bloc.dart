import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/logger.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_account_event.dart';
part 'delete_account_state.dart';
part 'delete_account_bloc.freezed.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  DeleteAccountBloc({
    required UserRepository userRepository,
    required FirebaseFunctionsHelper firebaseFunctionsHelper,
  }) : _userRepository = userRepository,
       _firebaseFunctionsHelper = firebaseFunctionsHelper,
       super(DeleteAccountState.initial()) {
    on<DeleteAccountEvent>(
      (event, emit) => event.map(
        deleteAccountEvent:
            (event) => _deleteAccountEvent(emit, event.userId, event.answers),
      ),
    );
  }

  final UserRepository _userRepository;
  final FirebaseFunctionsHelper _firebaseFunctionsHelper;

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
      return result.fold(
        (error) => logger.error('Error deleting account: $error'),
        (_) async {
          await _firebaseFunctionsHelper.disableCurrentUser();
          emit(state.copyWith(isLoading: false));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
