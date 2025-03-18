import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_felicitup_event.dart';
part 'message_felicitup_state.dart';
part 'message_felicitup_bloc.freezed.dart';

class MessageFelicitupBloc extends Bloc<MessageFelicitupEvent, MessageFelicitupState> {
  MessageFelicitupBloc() : super(MessageFelicitupState.initial()) {
    on<MessageFelicitupEvent>(
      (events, emit) => events.map(
        loadMessages: (_) => _loadMessages(emit),
      ),
    );
  }

  _loadMessages(Emitter<MessageFelicitupState> emit) {}
}
