import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/single_chat/bloc/single_chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late ChatRepository chatRepository;
  late UserRepository userRepository;
  late SingleChatBloc bloc;

  setUp(() {
    chatRepository = MockChatRepository();
    userRepository = MockUserRepository();
    bloc = SingleChatBloc(
      chatRepository: chatRepository,
      userRepository: userRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('SingleChatBloc', () {
    test('initial state is SingleChatState.initial()', () {
      expect(bloc.state, SingleChatState.initial());
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.currentChatId, isEmpty);
    });

    blocTest<SingleChatBloc, SingleChatState>(
      'emits updated currentChatId when setCurrentChatId is added',
      build: () => bloc,
      act: (b) => b.add(const SingleChatEvent.setCurrentChatId('chat123')),
      expect: () => [SingleChatState.initial().copyWith(currentChatId: 'chat123')],
    );
  });
}
