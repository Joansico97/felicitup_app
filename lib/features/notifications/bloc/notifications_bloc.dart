import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/models/push_message_model/push_message_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';
part 'notifications_bloc.freezed.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(NotificationsState.initial()) {
    on<NotificationsEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<NotificationsState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
