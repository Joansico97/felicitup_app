import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_settings_event.dart';
part 'notifications_settings_state.dart';
part 'notifications_settings_bloc.freezed.dart';

class NotificationsSettingsBloc
    extends Bloc<NotificationsSettingsEvent, NotificationsSettingsState> {
  NotificationsSettingsBloc() : super(NotificationsSettingsState.initial()) {
    on<NotificationsSettingsEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => emit(state.copyWith(isLoading: !state.isLoading)),
      ),
    );
  }
}
