import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late FirebaseAuth firebaseAuth;
  late UserRepository userRepository;
  late NotificationsBloc bloc;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    userRepository = MockUserRepository();
    bloc = NotificationsBloc(
      firebaseAuth: firebaseAuth,
      userRepository: userRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('NotificationsBloc', () {
    test('initial state is NotificationsState.initial()', () {
      expect(bloc.state, NotificationsState.initial());
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.notifications, isEmpty);
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'emits updated state when changeLoading is added',
      build: () => bloc,
      act: (b) => b.add(const NotificationsEvent.changeLoading()),
      expect: () => [NotificationsState.initial().copyWith(isLoading: true)],
    );
  });
}
