import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/felicitup_notification/bloc/felicitup_notification_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFelicitupRepository extends Mock implements FelicitupRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockFelicitupRepository mockFelicitupRepository;
  late MockUserRepository mockUserRepository;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFelicitupRepository = MockFelicitupRepository();
    mockUserRepository = MockUserRepository();
    mockFirebaseAuth = MockFirebaseAuth();
  });

  group('FelicitupNotificationBloc', () {
    test('initial state is correct', () {
      final bloc = FelicitupNotificationBloc(
        felicitupRepository: mockFelicitupRepository,
        userRepository: mockUserRepository,
        firebaseAuth: mockFirebaseAuth,
      );
      expect(bloc.state, FelicitupNotificationState.initial());
    });

    blocTest<FelicitupNotificationBloc, FelicitupNotificationState>(
      'toggles loading state on changeLoading',
      build: () => FelicitupNotificationBloc(
        felicitupRepository: mockFelicitupRepository,
        userRepository: mockUserRepository,
        firebaseAuth: mockFirebaseAuth,
      ),
      act: (bloc) => bloc.add(const FelicitupNotificationEvent.changeLoading()),
      expect: () => [
        FelicitupNotificationState.initial().copyWith(isLoading: true),
      ],
    );
  });
}
