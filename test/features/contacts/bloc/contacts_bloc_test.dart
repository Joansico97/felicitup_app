import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/contacts/bloc/contacts_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserRepository userRepository;
  late ContactsBloc bloc;

  setUp(() {
    userRepository = MockUserRepository();
    bloc = ContactsBloc(userRepository: userRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ContactsBloc', () {
    test('initial state is ContactsState.initial()', () {
      expect(bloc.state, ContactsState.initial());
      expect(bloc.state.isFirstTime, isTrue);
    });

    blocTest<ContactsBloc, ContactsState>(
      ('emits [isFirstTime: false] when changeIsFirstTime is added'),
      build: () => bloc,
      act: (b) => b.add(const ContactsEvent.changeIsFirstTime()),
      expect: () => [ContactsState.initial().copyWith(isFirstTime: false)],
    );
  });
}
