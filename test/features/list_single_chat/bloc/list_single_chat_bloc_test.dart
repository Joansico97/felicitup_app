import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/features/list_single_chat/bloc/list_single_chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ListSingleChatBloc bloc;

  setUp(() {
    bloc = ListSingleChatBloc();
  });

  tearDown(() {
    bloc.close();
  });

  group('ListSingleChatBloc', () {
    test('initial state is ListSingleChatState.initial()', () {
      expect(bloc.state, ListSingleChatState.initial());
      expect(bloc.state.isLoading, isFalse);
    });

    blocTest<ListSingleChatBloc, ListSingleChatState>(
      'emits updated state when changeLoading is added',
      build: () => bloc,
      act: (b) => b.add(const ListSingleChatEvent.changeLoading()),
      expect: () => [ListSingleChatState.initial().copyWith(isLoading: true)],
    );
  });
}
