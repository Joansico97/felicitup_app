import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';

part 'complete_user_data_event.dart';
part 'complete_user_data_state.dart';
part 'complete_user_data_bloc.freezed.dart';

class CompleteUserDataBloc
    extends Bloc<CompleteUserDataEvent, CompleteUserDataState> {
  CompleteUserDataBloc({
    required UserRepository userRepository,
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth,
       _userRepository = userRepository,
       super(CompleteUserDataState.initial()) {
    on<CompleteUserDataEvent>(
      (events, emit) => events.map(
        completeUserData:
            (event) => _completeUserData(emit, event.firstName, event.lastName),
        logout: (_) => _logout(emit),
      ),
    );
  }

  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth;

  _completeUserData(
    Emitter<CompleteUserDataState> emit,
    String firstName,
    String lastName,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.completeeUserInfo(
        firstName,
        lastName,
      );

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoading: false,
              status: CompleteUserDataStatus.error,
              errorMessage: failure.message,
            ),
          );
        },
        (user) {
          emit(
            state.copyWith(
              isLoading: false,
              status: CompleteUserDataStatus.success,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          status: CompleteUserDataStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  _logout(Emitter<CompleteUserDataState> emit) async {
    await _firebaseAuth.signOut();
    rootNavigatorKey.currentContext!.go(RouterPaths.login);
  }
}
