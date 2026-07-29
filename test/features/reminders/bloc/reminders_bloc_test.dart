import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/reminders/bloc/reminders_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late ChatRepository chatRepository;
  late UserRepository userRepository;
  late RemindersBloc bloc;

  setUp(() {
    chatRepository = MockChatRepository();
    userRepository = MockUserRepository();
    bloc = RemindersBloc(
      chatRepository: chatRepository,
      userRepository: userRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('RemindersBloc', () {
    test('initial state is RemindersState.initial()', () {
      expect(bloc.state, RemindersState.initial());
      expect(bloc.state.isLoading, isFalse);
    });

    blocTest<RemindersBloc, RemindersState>(
      'emits updated state when changeLoading is added',
      build: () => bloc,
      act: (b) => b.add(const RemindersEvent.changeLoading()),
      expect: () => [RemindersState.initial().copyWith(isLoading: true)],
    );
  });
}
