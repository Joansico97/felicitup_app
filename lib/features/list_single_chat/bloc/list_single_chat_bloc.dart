import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_single_chat_event.dart';
part 'list_single_chat_state.dart';
part 'list_single_chat_bloc.freezed.dart';

class ListSingleChatBloc extends Bloc<ListSingleChatEvent, ListSingleChatState> {
  ListSingleChatBloc() : super(ListSingleChatState.initial()) {
    on<ListSingleChatEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<ListSingleChatState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
