import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'single_chat_event.dart';
part 'single_chat_state.dart';
part 'single_chat_bloc.freezed.dart';

class SingleChatBloc extends Bloc<SingleChatEvent, SingleChatState> {
  SingleChatBloc() : super(SingleChatState.initial()) {
    on<SingleChatEvent>(
      (events, emit) => events.map(
        changeIsLoading: (_) => _changeIsLoading(emit),
      ),
    );
  }

  _changeIsLoading(Emitter<SingleChatState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
