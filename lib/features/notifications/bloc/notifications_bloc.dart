import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';
part 'notifications_bloc.freezed.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required FirebaseAuth firebaseAuth,
    required UserRepository userRepository,
  }) : _firebaseAuth = firebaseAuth,
       _userRepository = userRepository,
       super(NotificationsState.initial()) {
    on<NotificationsEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => emit(state.copyWith(isLoading: !state.isLoading)),
        getNotifications: (_) => _getNotifications(emit),
        deleteNotification: (event) =>
            _deleteNotification(emit, event.notificationId),
      ),
    );
  }
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  Future<void> _getNotifications(Emitter<NotificationsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      final response = await _userRepository.getUserData(uid!);

      response.fold(
        (l) {
          emit(state.copyWith(isLoading: false));
        },
        (r) {
          final user = UserModel.fromJson(r);
          emit(
            state.copyWith(
              isLoading: false,
              notifications: user.notifications!,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _deleteNotification(
    Emitter<NotificationsState> emit,
    String notificationId,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.deleteNotification(notificationId);

      response.fold(
        (l) {
          emit(state.copyWith(isLoading: false));
        },
        (r) {
          emit(state.copyWith(isLoading: false));
          add(NotificationsEvent.getNotifications());
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
